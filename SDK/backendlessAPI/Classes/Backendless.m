//
//  Backendless.m
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

#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessCache.h"
#import "Reachability.h"
#import "OfflineModeManager.h"

#define MISSING_SERVER_URL @"Missing server URL. You should set hostURL property"
#define MISSING_APP_ID @"Missing application ID argument. Login to Backendless Console, select your app and get the ID and key from the Manage > App Settings screen. Copy/paste the values into the [backendless initApp:secret:version:]"
#define MISSING_SECRET_KEY @"Missing secret key argument. Login to Backendless Console, select your app and get the ID and key from the Manage > App Settings screen. Copy/paste the values into the [backendless initApp:secret:version:]"
#define MISSING_VERSION_NUMBER @"Missing version number is argument. You should set versionNum  property"

//
static NSString *HOST_URL = @"https://api.backendless.com"; // api.backendless.com
//static NSString *HOST_URL = @"http://tc.themidnightcoders.com:9000"; // TC - 9000
//static NSString *HOST_URL = @"http://tc.themidnightcoders.com:9090"; // TC - 9090
//static NSString *HOST_URL = @"http://tc.themidnightcoders.com:9091"; // TC - 9091
//
//static NSString *HOST_URL = @"http://10.0.1.132:9090"; // backendless+wowza
//static NSString *HOST_URL = @"http://10.0.1.33:9000"; // me
//static NSString *HOST_URL = @"http://10.0.2.8:9000"; // Yura Yaschenko
//static NSString *HOST_URL = @"http://10.0.2.34:9000"; // Ivan Lappo
//static NSString *HOST_URL = @"http://10.0.2.11:9000"; // Oleg Oginsky
//static NSString *HOST_URL = @"http://10.0.1.14:9000"; // Sergey Kukurudzyak
//static NSString *HOST_URL = @"http://10.0.2.24:9000"; // Dmitry Naumenko
//static NSString *HOST_URL = @"http://10.0.1.54:9001"; // Dmitry Ivaschenko
//static NSString *HOST_URL = @"http://10.0.2.6:9000"; // Michael Cheremukhin
//
//static NSString *BACKENDLESS_MEDIA_STREAMING_URL = @"rtmp://10.0.1.132:1935/mediaApp"; // TC
//static NSString *BACKENDLESS_MEDIA_STREAMING_URL = @"rtmp://10.0.2.34:1935/mediaApp"; // Ivan Lappo

/*/---- Default application id & secret key arguments for iOS ---------
static NSString *APP_ID = @"validApp-Ids0-0000-0000-000000000000";
static NSString *SECRET_KEY = @"validSec-retK-eys0-0000-000000000003";
// for BackendlessDemosiOS application
static NSString *APP_ID = @"B5A98E56-E301-EE2F-FFDB-0B422FBBF800";
static NSString *SECRET_KEY = @"666FEFFD-4120-4B75-FFBF-B8E96C84C600";
/*///------------------------------------------------------------------

static NSString *VERSION_NUM = @"v1";
static NSString *APP_TYPE = @"IOS";
static NSString *API_VERSION = @"1.0";
//
static NSString *APP_ID_HEADER_KEY = @"application-id";
static NSString *SECRET_KEY_HEADER_KEY = @"secret-key";
static NSString *APP_TYPE_HEADER_KEY = @"application-type";
static NSString *API_VERSION_HEADER_KEY = @"api-version";
static NSString *UISTATE_HEADER_KEY = @"uiState";

@interface Backendless ()
{
}
@property (nonatomic, strong) Reachability *hostReachability;

@end

@implementation Backendless
@synthesize hostURL = _hostURL, versionNum = _versionNum, reachabilityDelegate = _reachabilityDelegate;
@synthesize mediaService = _mediaService, persistenceService = _persistenceService, messagingService = _messagingService, userService = _userService, fileService = _fileService, geoService = _geoService;
// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(Backendless *)sharedInstance {
	static Backendless *sharedBackendless;
	@synchronized(self)
	{
		if (!sharedBackendless)
			sharedBackendless = [Backendless new];
	}
	return sharedBackendless;
}

-(id)init {
	
    if ( (self=[super init]) ) {
        
        [OfflineModeManager sharedInstance].isOfflineMode = NO;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        [BETableView class];
        [BEMapView class];
        [BECollectionView class];
        
        
#endif
        
        
        _hostURL = [HOST_URL retain];
        _versionNum = [VERSION_NUM retain];
        
        _headers = [NSMutableDictionary new];
        [_headers setValue:APP_TYPE forKey:APP_TYPE_HEADER_KEY];
        [_headers setValue:API_VERSION forKey:API_VERSION_HEADER_KEY];
        
//        _userService = [UserService new];
//        _persistenceService = [PersistenceService new];
//        _geoService = [GeoService new];
//        _messagingService = [MessagingService new];
//        _fileService = [FileService new];
#ifdef __arm64__
        NSLog(@"Media Service are not available for arm64");
#else
//        _mediaService = [MediaService new];
#endif
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.hostReachability = [Reachability reachabilityWithHostName:_hostURL];
        [self.hostReachability startNotifier];
        
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Backendless"];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [_reachabilityDelegate release];
    [_hostReachability release];
    
    [_hostURL release];
    [_versionNum release];
    
    [_headers removeAllObjects];
    [_headers release];
    
    [_appConf release];
   
    [_userService release];
    [_persistenceService release];
    [_geoService release];
    [_messagingService release];
    [_fileService release];
    [_mediaService release];
	
	[super dealloc];
}

#pragma mark - getters 

-(MediaService *)mediaService
{
#ifdef __arm64__
    NSLog(@"Media Service are not available for arm64");
    return nil;
#else
    if (!_mediaService) {
        _mediaService = [MediaService new];
    }
    return _mediaService;
#endif
    
}

-(PersistenceService *)persistenceService
{
    if (!_persistenceService) {
        _persistenceService = [PersistenceService new];
    }
    return _persistenceService;
}

-(MessagingService *)messagingService
{
    if (!_messagingService) {
        _messagingService = [MessagingService new];
    }
    return _messagingService;
}
-(UserService *)userService
{
    if (!_userService) {
        _userService = [UserService new];
    }
    return _userService;
}
-(FileService *)fileService
{
    if (!_fileService) {
        _fileService = [FileService new];
    }
    return _fileService;
}

-(GeoService *)geoService
{
    if (!_geoService) {
        _geoService = [GeoService new];
    }
    return _geoService;
}
#pragma mark - reachability

-(NSInteger)getConnectionStatus
{
    return _hostReachability.currentReachabilityStatus;
}

- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* reachability = [note object];
	NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    if (netStatus != 0) {
        [[OfflineModeManager sharedInstance] startUploadData];
    }
    if ([_reachabilityDelegate respondsToSelector:@selector(changeNetworkStatus:connectionRequired:)]) {
        [_reachabilityDelegate changeNetworkStatus:netStatus connectionRequired:connectionRequired];
    }
}

#pragma mark -
#pragma mark getters / setters

-(void)setUIState:(NSString *)uiState
{
    [_headers setValue:uiState forKey:UISTATE_HEADER_KEY];
}
-(NSString *)getUIState
{
    return [_headers valueForKey:UISTATE_HEADER_KEY];
}
-(NSString *)getHostUrl {
    return _hostURL;
}

-(void)setHostUrl:(NSString *)hostURL {
    
    if ([_hostURL isEqualToString:hostURL])
        return;
    
    [_hostURL release];
    _hostURL = [hostURL retain];
    [invoker setup];
}

-(NSString *)getAppId {
    return [_headers valueForKey:APP_ID_HEADER_KEY];
}

-(void)setAppId:(NSString *)appID {
    
    if ([self.appID isEqualToString:appID])
        return;
    
    [_headers setValue:appID forKey:APP_ID_HEADER_KEY];
    [invoker setup];
}

-(NSString *)getSecretKey {
    return [_headers valueForKey:SECRET_KEY_HEADER_KEY];
}

-(void)setSecretKey:(NSString *)secretKey {
    
    if ([self.secretKey isEqualToString:secretKey])
        return;
    
    [_headers setValue:secretKey forKey:SECRET_KEY_HEADER_KEY];
    [invoker setup];
}

-(NSString *)getVersionNum {
    return _versionNum;
}

-(void)setVersionNum:(NSString *)versionNum {
    
    if ([_versionNum isEqualToString:versionNum])
        return;
    
    [_versionNum release];
    _versionNum = [versionNum retain];
    [invoker setup];
}

-(NSString *)getApiVersion {
    return [_headers valueForKey:API_VERSION_HEADER_KEY];
}

-(void)setApiVersion:(NSString *)apiVersion {
    
    if ([self.apiVersion isEqualToString:apiVersion])
        return;
    
    [_headers setValue:apiVersion  forKey:API_VERSION_HEADER_KEY];
    [invoker setup];
}

#pragma mark -
#pragma mark Public Methods

/**
 * Initializes the Backendless class and all Backendless dependencies.
 * This is the first step in using the client API.
 *
 * @param appId      a Backendless application ID, which could be retrieved at the Backendless console
 * @param secretKey  a Backendless application secret key, which could be retrieved at the Backendless console
 * @param versionNum identifies the version of the application. A version represents a snapshot of the configuration settings, set of schemas, user properties, etc.
 */

-(void)initApp:(NSString *)applicationID secret:(NSString *)secret version:(NSString *)version {
    
    [_headers setValue:applicationID forKey:APP_ID_HEADER_KEY];
    [_headers setValue:secret forKey:SECRET_KEY_HEADER_KEY];
    
    [_versionNum release];
    _versionNum = [version retain];
    
    [DebLog log:@"Backendless -> initApp: versionNum = %@, headers = \n%@", _versionNum, _headers];
    
    [invoker setup];    
}

-(void)initApp:(NSString *)plist {
    
    NSString *dataPath = [[NSBundle bundleForClass:[self class]] pathForResource:plist ofType:@"plist"];
    _appConf = (dataPath) ? [[NSDictionary dictionaryWithContentsOfFile:dataPath] retain] : nil;
    if (!self.appConf) {
        [DebLog log:@"Backendless -> initApp: file '%@.plist' is not found", plist];
        return;
    }
    
    [DebLog setIsActive:[_appConf[BACKENDLESS_DEBLOG_ON] boolValue]];
    [backendless initApp:_appConf[BACKENDLESS_APP_ID] secret:_appConf[BACKENDLESS_SECRET_KEY] version:_appConf[BACKENDLESS_VERSION_NUM]];
}

-(void)initApp {
    [self initApp:BACKENDLESS_APP_CONF];
}

-(void)initAppFault {
    
    NSString *value;
    if (!(value = [self getHostUrl]) || !value.length)
        [self throwFault:[Fault fault:MISSING_SERVER_URL faultCode:@"0001"]];
    else if (!(value = [self getAppId]) || !value.length)
        [self throwFault:[Fault fault:MISSING_APP_ID faultCode:@"0002"]];
    else if (!(value = [self getSecretKey]) || !value.length)
        [self throwFault:[Fault fault:MISSING_SECRET_KEY faultCode:@"0003"]];
    else if (!(value = [self getVersionNum]) || !value.length)
        [self throwFault:[Fault fault:MISSING_VERSION_NUMBER faultCode:@"0004"]];
}

-(NSString *)mediaServerUrl {
    return [NSString stringWithFormat:@"rtmp://%@:1935/mediaApp", [[NSURL URLWithString:_hostURL] host]];
}

-(void)setThrowException:(BOOL)needThrow {
    invoker.throwException = needThrow;
}

-(id)throwFault:(Fault *)fault {
    if (invoker.throwException)
        @throw fault;
    return fault;
}

-(NSString *)GUIDString {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return [(NSString *)string autorelease];
}

// Generates a random string of up to 1000 characters in length. Generates a random length up to 1000 if numCharacters is set to 0
-(NSString *)randomString:(int)numCharacters {
    
    static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    int len = (numCharacters > 1000 || numCharacters == 0) ? (int)rand() % (1000) : numCharacters;    
    unichar characters[len];
    for( int i=0; i < len; ++i ) {
        characters[i] = possibleChars[arc4random_uniform(sizeof(possibleChars)-1)];
    }
    
    return [[NSString stringWithCharacters:characters length:len] autorelease];
}

-(NSString *)applicationType {
    return APP_TYPE;
}

#pragma mark - cache
-(void)clearAllCache
{
    [backendlessCache clearAllCache];
}
-(void)clearCacheForClassName:(NSString *)className query:(id)query
{
    [backendlessCache clearCacheForClassName:className query:query];
}
-(BOOL)hasResultForClassName:(NSString *)className query:(id)query
{
    return [backendlessCache hasResultForClassName:className query:query];
}
-(void)setCachePolicy:(BackendlessCachePolicy *)policy
{
    [backendlessCache setCachePolicy:policy];
}
-(void)setCacheStoredType:(BackendlessCacheStoredEnum)storedType
{
    if (backendlessCache.storedType.integerValue == BackendlessCacheStoredDisc) {
        [backendlessCache saveOnDisc];
    }
    [backendlessCache storedType:storedType];
}
-(void)saveCache
{
    if (backendlessCache.storedType.integerValue == BackendlessCacheStoredDisc) {
        [backendlessCache saveOnDisc];
    }
   
}
#pragma mark - offline mode
-(void)setOfflineMode:(BOOL)offlineMode
{
    if (offlineMode) {
        [invoker setThrowException:NO];
    }
    [OfflineModeManager sharedInstance].isOfflineMode = offlineMode;
}

@end
