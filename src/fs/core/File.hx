package fs.core;

import tink.http.Header.HeaderField;
import tink.http.Client;
import tink.http.Request;
import tink.http.Method;
import tink.url.Path;
import tink.Url;

import haxe.ds.StringMap;
import haxe.io.Bytes;

#if js
import js.Browser;
#else
import asys.FileSystem;
#end

using StringTools;
using PromiseTools;
using tink.CoreApi;

typedef RequestData = {
    ?method: Method,
    url: String,
    ?headers: Map<String, String>,
    ?body: String
}

@await class File {

    #if js
    private static var _httpClient = new JsClient();
    #else
    private static var _httpClient = new StdClient();
    #end

    private static var _cache : StringMap<Bytes> = new StringMap();

    /**
     *  Add Bytes to cache with path as key
     *  
     *  @param path - Path to use as key
     *  @param bytes - Bytes to cache
     *  @return The bytes passed in as params for chaining
     */
    private static function addCache( path : String, bytes : Bytes ) : Bytes {
        _cache.set(path, bytes);
        return bytes;
    }

    /**
     *  Load a file from disk or download if js target
     *  
     *  @param path - Path of the file to load
     *  @param cache - If we allow caching of the bytes for further use
     *  @return Content of the file as Bytes
     */
    @async public static function load( path : String, ?cache:Bool = true ) : Bytes {
        // Check from cache
        if (cache && _cache.exists(path)) {
            return _cache.get(path);
        }

        #if js
        // Download on js since there is no file system
        return @await download(path, cache);
        #else
        // Use `asys`lib to load from disk async
        return @await FileSystem.exists(path)
        .flatMap((exists) -> if (exists) {
            asys.io.File.getBytes(path).fromNullable();
        } else {
            Future.sync(Failure(new Error('File does not exist')));
        })
        .onSuccess((bytes) -> if (cache) _cache.set(path, bytes))
        .defer();
        #end
    }

    /**
     *  See `load`, return String instead of Bytes
     *  
     *  @param path - Path of the file to load
     *  @param cache - If we allow caching of the bytes for further use
     *  @return Content of the file as String
     */
    @async public static function loadString( path : String, ?cache:Bool = true ) : String {
        return @await load(path, cache).map((outcome) -> 
            outcome.map((bytes) -> bytes.toString()));
    }

    /**
     *  Download a file based on a path, without a `host` or 
     *  `protocol` get the current one 
     *  
     *  @param path - 
     *  @param cache - 
     *  @return Bytes
     */
    @async public static function download( path : String, ?cache:Bool = true ) : Bytes {
        var _path = path;
        
        // Check from cache
        if (cache && _cache.exists(_path)) {
            return _cache.get(_path);
        }

        #if js
        // Format the path to URL
        var url = Url.parse(path);
        
        // Assume this is an invalid URL and so create an URL that is relative to the app
        if (url.host == null) {
            var location = Browser.location;
            var locationUrl = Url.parse(location.href);
            var parts = Path.ofString(locationUrl.path).parts();

            // Remove the last part (index.html)
            if (!location.href.endsWith('/')) parts.pop();

            // Create final url
            path = '${locationUrl.scheme}://${locationUrl.host}/${parts.join('/')}/${path}';    
        }
        #end
        
        // Download file from http
        return @await _httpClient
        .request(ClientRequest.fromData({
            method: Method.GET,
            url: path
        }))
        .flatMap((response) -> switch(response.header.statusCode) {
            case 200 : response.body.all();
            default : Future.sync(Failure(new Error('Bad http response')));
        })
        .onSuccess((bytes) -> if (cache) _cache.set(_path, bytes))
        .defer();
    }

    /**
     *  Download a file and return a String
     *  
     *  @param path - 
     *  @param cache - 
     *  @return String
     */
    @async public static function downloadString( path : String, ?cache:Bool = true ) : String {
        return @await download(path, cache).map((outcome) -> 
            outcome.map((bytes) -> bytes.toString()));
    }
}

abstract ClientRequest(RequestData) {
    inline function new(data: RequestData) {
        if (data.body == null) data.body = '';
        if (data.method == null) data.method = Method.GET;
        this = data;
    }
  
    @:from public static function fromData(data: RequestData)
        return new ClientRequest(data);
        
    function fields()
        return switch this.headers {
            case null: [];
            case v: [
                for (key in this.headers.keys())
                    new HeaderField(key, this.headers.get(key))
            ];
    }
  
    @:to public function toOutgoing(): OutgoingRequest {
        var url = Url.parse(this.url);
        return 
            new OutgoingRequest(
                new OutgoingRequestHeader(
                    this.method, 
                    url.host, 
                    url.path, 
                    fields()
                ), 
                this.body
            );
    }
}