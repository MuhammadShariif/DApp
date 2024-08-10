import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";





actor Token{
    var owner : Principal = Principal.fromText("ahrav-dco77-mhjrl-oruoq-g5p3j-ffvgj-waxtn-ipz5s-45dzc-6oy6z-vqe");
    var totalSupply : Nat = 1000000000;
    var symbol : Text = "DANG";

    private stable var balanceEntries : [(Principal, Nat)] = [];
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
     
    public query func balanceOf(who : Principal) : async Nat {
        let balance : Nat = switch(balances.get(who)) {
            case(null) { 0 };
            case(?result) { result };
        };
        return balance;
    }; 

    public query func currencyName() : async Text {
        return symbol;
    };

    public shared(msg) func payOut() : async Text {
        Debug.print(debug_show (msg.caller));
        if (balances.get(msg.caller) == null){
            let amount : Nat = 10000;
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            return "Already Gained";
        }
    };

    public shared(msg) func transfer(to : Principal, amount : Nat) : async Text {
        
        let fromBalance = await balanceOf(msg.caller);
        if (fromBalance >= amount){
            let newFromBalance : Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount;
            balances.put(to, newToBalance);
            return "success";
        } else {
            return "insuficient balance"
        }
        
    };

    system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries())
    };

    system func postupgrade(){
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        if(balances.size() < 1){
            balances.put(owner, totalSupply);
        }
    };
}