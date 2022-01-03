import Text "mo:base/Text";
import Nat "mo:base/Nat";
actor Counter {
  public type HeaderField = (Text, Text);

  public type HttpRequest = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type HttpResponse = {
    body : Blob;
    headers : [HeaderField];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };

  public type Key = Text;
  public type Path = Text;
  public type StreamingCallbackHttpResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
  };
  public type StreamingCallbackToken = {
    key : Text;
    sha256 : ?[Nat8];
    index : Nat;
    content_encoding : Text;
  };
  public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : shared query StreamingCallbackToken -> async StreamingCallbackHttpResponse;
    };
  };


  stable var counter = 0;

  // Get the value of the counter.
  public query func get() : async Nat {
    return counter;
  };

  // Set the value of the counter.
  public func set(n : Nat) : async () {
    counter := n;
  };

  // Increment the value of the counter.
  public func inc() : async () {
    counter += 1;
  };

  public shared query func http_request(request:HttpRequest): async HttpResponse {
      {
          body = Text.encodeUtf8("<html><body>"#Nat.toText(counter)#"</body></html>");
          headers = [];
          streaming_strategy = null;
          status_code = 200;
      }
  }
  
};