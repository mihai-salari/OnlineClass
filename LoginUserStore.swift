//
//  LoginUserStore.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/3/2.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import CoreData

class LoginUserStore {
    var coreDataStack = CoreDataStack(modelName: Utils.Model_Name)
    
    func saveLoginUser(userName: String, password: String, name: String, token: String) -> Bool {
        removeLoginUser()
        
        //存储登录的信息
        let context = coreDataStack.mainQueueContext
        var user: LoginUserEntity!
        context.performBlockAndWait() {
            user = NSEntityDescription.insertNewObjectForEntityForName("LoginUserEntity", inManagedObjectContext: context) as! LoginUserEntity
            user.userName = userName
            user.password = password
            user.name = name
            user.lastLoginTime = NSDate()
            user.token = token
        }
        
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
    }
    
    func getLoginUser() -> LoginUserEntity? {
        let fetchRequest = NSFetchRequest(entityName: "LoginUserEntity")
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = nil
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [LoginUserEntity]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.executeFetchRequest(fetchRequest) as? [LoginUserEntity]
            }
            catch let error {
                fetchRequestError = error
                NSLog("GetLoginUser()出现异常")
            }
        }
        
        if fetchRequestError == nil {
            if mainQueueUsers?.count == 0 {
                return nil
            } else {
                return mainQueueUsers![0]
            }
        }
        
        return nil
    }
    
    func removeLoginUser() {
        let loginUser = getLoginUser()
        if loginUser != nil {
            let context = coreDataStack.mainQueueContext
            context.performBlockAndWait() {
                do {
                    context.deleteObject(loginUser!)
                    try self.coreDataStack.saveChanges()
                }
                catch  {
                    NSLog("removeLoginUser throw Error")
                }
            }
        }
    }
}