//
//  CartridgeSyncer.swift
//  Pods
//
//  Created by Akash Desai on 7/22/16.
//
//

import Foundation

@objc
class CartridgeSyncer : NSObject {
    
    static let sharedInstance: CartridgeSyncer = CartridgeSyncer()
    
    /// Used to store actionIDs so cartridges can be loaded on init()
    ///
    private let defaultsActionIDSetKey = "DopamineActionIDSet"
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    /// All the cartridges
    ///
    private var cartridges:[String:Cartridge] = [:]
    
    private var syncInProgress = false
    
    private override init() {
        if let savedActionIDSetData = defaults.objectForKey(defaultsActionIDSetKey) as? [String] {
            for actionID in savedActionIDSetData {
                cartridges[actionID] = Cartridge(actionID: actionID)
            }
        }
    }
    
    /// Unloads a cartridge for an action
    ///
    /// - parameters:
    ///     - action: An action to be reinforced.
    ///
    /// - returns:
    ///     A reinforcement decision for the given action.
    ///
    func unloadReinforcementDecisionForAction(action: DopeAction) -> String {
        let cartridge = getCartridgeForActionID(action.actionID)
        return cartridge.remove()
    }
    
    /// Checks if any cartridge has been triggered to sync yet
    ///
    /// - returns: Whether a cartridge needs to sync.
    ///
    func shouldSync() -> Bool {
        for (_, cartridge) in cartridges {
            if cartridge.isTriggered() {
                return true
            }
        }
        DopamineKit.DebugLog("No cartridges to sync.")
        return false
    }
    
    /// Checks which cartridges have been triggered to sync
    ///
    /// - returns: An array of the actionIDs for cartridges that need to sync.
    ///
    func whichShouldSync() -> [String] {
        var actionIDsToSync: [String] = []
        for (actionID, cartridge) in cartridges {
            if cartridge.isTriggered() {
                actionIDsToSync.append(actionID)
            }
        }
        return actionIDsToSync
    }
    
    /// Sends tracked actions over the DopamineAPI
    ///
    /// - parameters:
    ///     - completion(Int): takes the http response status code as a parameter.
    ///
    func sync(actionID: String, completion: (Int) -> () = { _ in }) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            guard !self.syncInProgress else {
                DopamineKit.DebugLog("Cartridge sync already happening")
                completion(200)
                return
            }
            
            self.syncInProgress = true
            let cartridge = self.getCartridgeForActionID(actionID)
            
            DopamineAPI.refresh(cartridge.actionID) { response in
                defer { self.syncInProgress = false }
                if response["status"] as? Int == 200,
                    let cartridgeDecisions = response["reinforcementCartridge"] as? [String],
                    let expiresIn = response["expiresIn"] as? Int
                {
                    defer { completion(200) }
                    
                    cartridge.removeAll()
                    for decision in cartridgeDecisions {
                        cartridge.add(decision)
                    }
                    cartridge.updateTriggers(cartridgeDecisions.count, timerExpiresIn: Int64(expiresIn) )
                    
                    DopamineKit.DebugLog("✅ \(cartridge.actionID) refreshed!")
                }
                else {
                    DopamineKit.DebugLog("❌ Could not read cartridge for (\(cartridge.actionID))")
                    completion(404)
                }
            }
        }
    }
    
    
    /// Retrieves a cartidge for a given action, or creates a cartidge if one doesn't exist
    ///
    /// - parameters:
    ///     - actionID: The action to retrieve a cartridge for. 
    ///                 If a cartridge doesn't exist, one is created and saved.
    ///
    /// - returns:
    ///     A cartridge for the given actionID.
    ///
    private func getCartridgeForActionID(actionID: String) -> Cartridge {
        if let cartridge = cartridges[actionID] {
            return cartridge
        } else {
            let cartridge = Cartridge(actionID: actionID)
            cartridges[actionID] = cartridge
            let actionIDs = cartridges.keys.sort()
            defaults.setObject(actionIDs, forKey: defaultsActionIDSetKey)
            return cartridge
        }
    }
    
    /// Removes all saved cartridge actionIDs and cartridge triggers from memory
    ///
    func reset() {
        for (_, cartridge) in cartridges {
            cartridge.resetTriggers()
        }
        cartridges.removeAll()
        defaults.removeObjectForKey(defaultsActionIDSetKey)
    }
    
    
}


