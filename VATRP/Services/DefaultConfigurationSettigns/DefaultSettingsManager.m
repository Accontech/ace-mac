//
//  DefaultSettingsManager.m
//  linphone
//
//  Created by User on 17/12/15.
//
//

#import "DefaultSettingsManager.h"
#import "SRVResolver.h"
#import "SettingsConstants.h"
#import "Utils.h"

@interface DefaultSettingsManager () <SRVResolverDelegate, NSURLConnectionDelegate>
//{
//    UIActivityIndicatorView *aiv;
//}
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (nonatomic, strong) SRVResolver *  resolver;

@end

@implementation DefaultSettingsManager

static DefaultSettingsManager *sharedInstance = nil;

+ (id)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)parseDefaultConfigSettingsFromURL:(NSString*)configURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:self.userName
                                                   password:self.password
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary* normalizedDict = [Utils normalizeServerDictionary:jsonDict];
    [self storeToUserDefaults:normalizedDict];
    //[aiv stopAnimating];
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingConfigData)]) {
        [self.delegate didFinishLoadingConfigData];
    }
}

- (void)parseDefaultConfigSettingsFromFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config_defaults" ofType:@"json"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
    NSDictionary* normalizedDict = [Utils normalizeServerDictionary:jsonDict];
    [self storeToUserDefaults:normalizedDict];
}

- (void)parseDefaultConfigSettings:(NSString*)configAddress withUsername:(NSString*)userName andPassword:(NSString*)password {
    self.userName = userName;
    self.password = password;
    //[self parseDefaultConfigSettingsFromURL];
    self.resolver = [[SRVResolver alloc] initWithSRVName:configAddress];
    self.resolver.delegate = self;
    [self.resolver start];
}

- (void)clearDefaultConfigSettings {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

// ToDo: Liz E., Post GA - fix the rest of the settings constants.
// Ensure that all dictionaries passed to this method have been passed through the [Utils normalizeServerDictionary method.
- (void)storeToUserDefaults:(NSDictionary*)dict {
    
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"version"] forKey:@"version"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:([dict objectForKey:@"expiration_time"] != [NSNull null])?[[dict objectForKey:@"expiration_time"] integerValue]:280 forKey:@"expiration_time" ];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"configuration_auth_password"] != [NSNull null])?[dict objectForKey:@"configuration_auth_password"]:@"" forKey:@"configuration_auth_password"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"configuration_auth_expiration"] != [NSNull null])?[dict objectForKey:@"configuration_auth_expiration"]:@"" forKey:@"configuration_auth_expiration"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_registration_maximum_threshold"] != [NSNull null])?[dict objectForKey:@"sip_registration_maximum_threshold"]:@"" forKey:@"sip_registration_maximum_threshold"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_register_usernames"] != [NSNull null])?[dict objectForKey:@"sip_register_usernames"]:@"" forKey:@"sip_register_usernames"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_auth_username"] != [NSNull null])?[dict objectForKey:@"sip_auth_username"]:@"" forKey:@"sip_auth_username"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_auth_password"] != [NSNull null])?[dict objectForKey:@"sip_auth_password"]:@"" forKey:@"sip_auth_password"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_register_domain"] != [NSNull null])?[dict objectForKey:@"sip_register_domain"]:@"" forKey:@"sip_register_domain"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:([dict objectForKey:@"sip_register_port"] != [NSNull null])?[[dict objectForKey:@"sip_register_port"] integerValue]:0 forKey:@"sip_register_port"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:SIP_REGISTER_TRANSPORT] != [NSNull null])?[dict objectForKey:SIP_REGISTER_TRANSPORT]:@"" forKey:SIP_REGISTER_TRANSPORT];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_echo_cancellation"] != [NSNull null])? [dict objectForKey:@"enable_echo_cancellation"]:@"" forKey:@"enable_echo_cancellation"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_video"] != [NSNull null])?[dict objectForKey:@"enable_video"]:@"true" forKey:ENABLE_VIDEO];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_rtt"] != [NSNull null])?[dict objectForKey:@"enable_rtt"]:@"" forKey:@"kREAL_TIME_TEXT_ENABLED"];
    
//TEMP for VATRP-3512    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_adaptive_rate"] != [NSNull null])?[dict objectForKey:@"enable_adaptive_rate"]:@"" forKey:@"enable_adaptive_rate_control"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enabled_codecs"] != [NSNull null])?[dict objectForKey:@"enabled_codecs"]:@[@"H.264", @"H.263", @"VP8", @"G.722", @"G.711"] forKey:@"enabled_codecs"];
//    NSArray* test = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_codecs"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"bwLimit"] != [NSNull null])?[dict objectForKey:@"bwLimit"]:@"" forKey:@"bwLimit"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:([dict objectForKey:UPLOAD_BANDWIDTH] != [NSNull null])?[[dict objectForKey:UPLOAD_BANDWIDTH] integerValue]:1500 forKey:UPLOAD_BANDWIDTH ];
    
    [[NSUserDefaults standardUserDefaults] setInteger:([dict objectForKey:DOWNLOAD_BANDWIDTH] != [NSNull null])?[[dict objectForKey:DOWNLOAD_BANDWIDTH] integerValue]:1500 forKey:DOWNLOAD_BANDWIDTH ];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_stun"] != [NSNull null])?[dict objectForKey:@"enable_stun"]:@"true" forKey:ENABLE_STUN];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"stun_server"] != [NSNull null])?[dict objectForKey:@"stun_server"]:@"" forKey:STUN_SERVER_DOMAIN];

    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"enable_ice"] != [NSNull null])? [dict objectForKey:@"enable_ice"]:@"false" forKey:ENABLE_ICE];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"logging"] != [NSNull null])? [dict objectForKey:@"logging"]:@"" forKey:@"logging"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:@"sip_mwi_uri"] != [NSNull null])? [dict objectForKey:@"sip_mwi_uri"]:@"" forKey:@"sip_mwi_uri"];
    
    [[NSUserDefaults standardUserDefaults] setObject:([dict objectForKey:VIDEO_MAIL_URI] != [NSNull null])?[dict objectForKey:VIDEO_MAIL_URI]:@"" forKey:VIDEO_MAIL_URI];
    
    NSString* valueToStore;
    if ([dict objectForKey:@"video_resolution_maximum"] != nil)
    {
        // convert incoming to the strings that we are using:
        NSString* value = [dict objectForKey:@"video_resolution_maximum"];
        if ([value isEqualToString:@"1090p"])
            valueToStore = @"1080p (1920x1080)";
        else if ([value isEqualToString:@"720p"])
            valueToStore = @"720p (1280x720)";
        else if ([value isEqualToString:@"svga"])
            valueToStore = @"svga (800x600)";
        else if ([value isEqualToString:@"4cif"])
            valueToStore = @"4cif (704x576)";
        else if ([value isEqualToString:@"vga"])
            valueToStore = @"vga (640x480)";
        else if ([value isEqualToString:@"qcif"])
            valueToStore = @"qcif (176x144)";
        else if ([value isEqualToString:@"cif"])
            valueToStore = @"cif (352x288)";
    }
    if (valueToStore == nil) // our current default
        valueToStore = @"vga (640x480)";

    [[NSUserDefaults standardUserDefaults] setObject:valueToStore forKey:PREFERRED_VIDEO_RESOLUTION];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark set fields functions 

- (void)setSipRegisterUserNames:(NSArray *)sipRegisterUsernames {
    [[NSUserDefaults standardUserDefaults] setObject:sipRegisterUsernames forKey:@"sip_register_usernames"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipAuthUsername:(NSString *)sipAuthUsername {
    [[NSUserDefaults standardUserDefaults] setObject:sipAuthUsername forKey:@"sip_auth_username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipAuthPassword:(NSString *)sipAuthPassword {
    [[NSUserDefaults standardUserDefaults] setObject:sipAuthPassword forKey:@"sip_auth_password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipRegisterDomain:(NSString *)sipRegisterDomain {
    [[NSUserDefaults standardUserDefaults] setObject:sipRegisterDomain forKey:@"sip_register_domain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipRegisterPort:(int)sipRegisterPort {
    [[NSUserDefaults standardUserDefaults] setInteger:sipRegisterPort forKey:@"sip_register_port"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipMwUri:(NSString *)sipMwiUri {
    [[NSUserDefaults standardUserDefaults] setObject:sipMwiUri forKey:@"sip_mwi_uri"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSipVideomailUri:(NSString *)sipVideomailUri {
    [[NSUserDefaults standardUserDefaults] setObject:sipVideomailUri forKey:VIDEO_MAIL_URI];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - get fields functions

- (NSNumber*)version {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
}

- (NSString*)configAuthPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"configuration_auth_password"];
}

- (int)exparitionTime {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"expiration_time"];
}

- (NSString*)configAuthExpiration {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"configuration_auth_expiration"];
}

- (NSString*)sipRegistrationMaximumThreshold {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_registration_maximum_threshold"];
}

- (NSMutableArray*)sipRegisterUsernames {
    return (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"sip_register_usernames"];
}

- (NSString*)sipRegisterUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_register_username"];
}

- (NSString*)sipAuthUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_auth_username"];
}

- (NSString*)sipAuthPassword {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_auth_password"];
}

- (NSString*)sipRegisterDomain {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_register_domain"];
}

- (int)sipRegisterPort {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"sip_register_port"];
}

- (NSString*)sipRegisterTransport {
    return [[NSUserDefaults standardUserDefaults] stringForKey:SIP_REGISTER_TRANSPORT];
}

- (BOOL)enableEchoCancellation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_echo_cancellation"];
}

- (BOOL)enableVideo {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_VIDEO];
}

- (BOOL)enableRtt {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kREAL_TIME_TEXT_ENABLED"];
}

- (BOOL)enableAdaptiveRate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_adaptive_rate_control"];
}

- (NSArray*)enabledCodecs {

    return [[self removeDotsFromArray:(NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_codecs"]] copy];
}

- (NSString*)bwLimit {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"bwLimit"];
}

- (int)uploadBandwidth {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:UPLOAD_BANDWIDTH];
}

- (int)downloadBandwidth {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:DOWNLOAD_BANDWIDTH];
}

- (BOOL)enableStun {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_STUN];
}

- (NSString*)stunServer {
    return [[NSUserDefaults standardUserDefaults] stringForKey:STUN_SERVER_DOMAIN];
}

- (BOOL)enableIce {    
    return [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_ICE];
}

- (NSString*)logging {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"logging"];
}

- (NSString*)sipMwiUri {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sip_mwi_uri"];
}

- (NSString*)sipVideomailUri {
    return [[NSUserDefaults standardUserDefaults] stringForKey:VIDEO_MAIL_URI];
}

- (NSString*)videoResolutionMaximum {
    return [[NSUserDefaults standardUserDefaults] stringForKey:PREFERRED_VIDEO_RESOLUTION];
}

#pragma mark - helper functions

- (NSMutableArray*)removeDotsFromArray:(NSArray*)arrayWithDots {
    NSMutableArray *arrayWithoutArray = [NSMutableArray new];
    
    for (NSString *str in arrayWithDots) {
        NSString *stringWithoutDot = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
        [arrayWithoutArray addObject:stringWithoutDot];
    }
    
    
    return arrayWithoutArray;
}

#pragma mark - SRVResolver delegate methods

- (void)srvResolver:(SRVResolver *)resolver didReceiveResult:(NSDictionary *)result {
    assert(resolver == self.resolver);
    #pragma unused(resolver)
    assert(result != nil);
    NSString *configURL = [result objectForKey:@"target"];
    NSString *configURLPath = [[@"https://" stringByAppendingString:configURL] stringByAppendingString:@"/config/v1/config.json"];
    [self parseDefaultConfigSettingsFromURL:configURLPath];
}

- (void)srvResolver:(SRVResolver *)resolver didStopWithError:(NSError *)error {
    assert(resolver == self.resolver);
    #pragma unused(resolver)
    NSLog(@"didStopWithError %@", error);
    if(self.delegate){
        [self.delegate didFinishWithError ];//: error];
    }
}

@end
