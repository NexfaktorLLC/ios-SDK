//
//  DataStoreFactory.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "DataStoreFactory.h"
#include "Responder.h"
#include "Backendless.h"

@interface DataStoreFactory () {
    Class _entityClass;
}
@end

@implementation DataStoreFactory
-(id)init {
	if ( (self=[super init]) ) {
        _entityClass = nil;
	}
	
	return self;
}

-(id)init:(Class)entityClass {
	if ( (self=[super init]) ) {
        _entityClass = [entityClass retain];
	}
	
	return self;
}

+(id <IDataStore>)createDataStore:(Class)entityClass {
    return [[DataStoreFactory alloc] init:entityClass];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC DataStoreFactory"];
    
    if (_entityClass) [_entityClass release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(id)propertyValue:(NSString *)propertyName of:(id)entity {
    return [[Types propertyDictionary:entity] objectForKey:propertyName];
}

#pragma mark -
#pragma mark IDataStore Methods

// sync methods

-(id)save:(id)entity {
    return [backendless.persistenceService save:entity];
}

-(id)findID:(NSString *)objectID {
    return [backendless.persistenceService findByClassId:_entityClass sid:objectID];
}

-(NSNumber *)remove:(id)entity {
    return [backendless.persistenceService remove:[entity class] sid:[self propertyValue:PERSIST_OBJECT_ID of:entity]];
}

-(NSNumber *)removeID:(NSString *)objectID {
    return [backendless.persistenceService remove:_entityClass sid:objectID];
}

-(void)removeAll:(BackendlessDataQuery *)dataQuery {
    [backendless.persistenceService removeAll:_entityClass dataQuery:dataQuery];
}

-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery {
    return [backendless.persistenceService find:_entityClass dataQuery:dataQuery];
}

-(id)findFirst {
    return [backendless.persistenceService first:_entityClass];
}

-(id)findLast {
    return [backendless.persistenceService last:_entityClass];
}
-(NSArray *)describe
{
    return [backendless.persistenceService describe:NSStringFromClass(_entityClass)];
}
-(void)load:(id)object relations:(NSArray *)relations
{
    [backendless.persistenceService load:object relations:relations];
}

// async methods with responder

-(void)save:(id)entity responder:(id <IResponder>)responder {
    [backendless.persistenceService save:entity responder:responder];
}

-(void)findID:(NSString *)objectID responder:(id <IResponder>)responder {
    [backendless.persistenceService findByClassId:_entityClass sid:objectID responder:responder];
}

-(void)remove:(id)entity responder:(id <IResponder>)responder {
    [backendless.persistenceService remove:[entity class] sid:[self propertyValue:PERSIST_OBJECT_ID of:entity] responder:responder];
}

-(void)removeID:(NSString *)objectID responder:(id <IResponder>)responder {
    [backendless.persistenceService remove:_entityClass sid:objectID responder:responder];
}

-(void)removeAll:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    [backendless.persistenceService removeAll:_entityClass dataQuery:dataQuery responder:responder];
}

-(void)find:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    [backendless.persistenceService find:_entityClass dataQuery:dataQuery responder:responder];
}

-(void)findFirst:(id <IResponder>)responder {
    [backendless.persistenceService first:_entityClass responder:responder];
}

-(void)findLast:(id <IResponder>)responder {
    [backendless.persistenceService last:_entityClass responder:responder];
}
-(void)describeResponder:(id<IResponder>)responder
{
    [backendless.persistenceService describe:NSStringFromClass(_entityClass) responder:responder];
}
-(void)load:(id)object relations:(NSArray *)relations responder:(id<IResponder>)responder
{
    [backendless.persistenceService load:object relations:relations responder:responder];
}
// async methods with block-base callbacks

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService save:entity response:responseBlock error:errorBlock];
}

-(void)findID:(NSString *)objectID response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService findByClassId:_entityClass sid:objectID response:responseBlock error:errorBlock];
}

-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService remove:[entity class] sid:[self propertyValue:PERSIST_OBJECT_ID of:entity] response:responseBlock error:errorBlock];
}

-(void)removeID:(NSString *)objectID response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService remove:_entityClass sid:objectID response:responseBlock error:errorBlock];
}

-(void)removeAll:(BackendlessDataQuery *)dataQuery responder:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService removeAll:_entityClass dataQuery:dataQuery response:responseBlock error:errorBlock];
}

-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService find:_entityClass dataQuery:dataQuery response:responseBlock error:errorBlock];
}

-(void)findFirst:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService first:_entityClass response:responseBlock error:errorBlock];
}

-(void)findLast:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [backendless.persistenceService last:_entityClass response:responseBlock error:errorBlock];
}
-(void)describeResponse:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock
{
    [backendless.persistenceService describe:NSStringFromClass(_entityClass) response:responseBlock error:errorBlock];
}
-(void)load:(id)object relations:(NSArray *)relations response:(void (^)(BackendlessCollection *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [backendless.persistenceService load:object relations:relations response:responseBlock error:errorBlock];
}
@end
