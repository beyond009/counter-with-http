import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Int "mo:base/Int";

actor {
    private type Message = {
        text : Text;
        author : Text;
        time : Time.Time;
    };

    private type Microblog = actor{
        follow: shared (Principal) -> async ();
        follows: shared query() -> async [Principal];
        post: shared (Text,Text) -> async ();
        posts: shared query () -> async [Message];
        timeline: shared () -> async [Message];
    };

    stable var followed : List.List<Principal> = List.nil();
    private stable var auth: ?Text = null;
    public shared func set_name(t: Text) : async () {
        auth := ?t;
    };

    public query func get_name() : async ?Text {
        auth
    };

    public shared func follow(id: Principal) : async () {
        followed := List.push(id, followed);
    };
    
    public query func follows() : async [Principal] {
        return List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();

    public shared ({caller}) func post(opt: Text,text : Text) : async () {
        assert(opt == "suckmydick");
        let _author = switch (auth) {
            case (?a) { a };
            case (null) { "" };
        };
        var msg : Message = {
            text = text;
            author = _author; 
            time = Time.now();
        };
        messages := List.push(msg, messages);
    };

    public shared query func posts() : async [Message] {
        return List.toArray(messages);
    };


    public shared func timeline() : async [Message] {
        var all : List.List<Message> = List.nil();

        for(id in Iter.fromList(followed)){
            let canister : Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts();
            for(msg in Iter.fromArray(msgs)){
                all := List.push(msg, all);
            };
        };

        return List.toArray(all);
    };
};