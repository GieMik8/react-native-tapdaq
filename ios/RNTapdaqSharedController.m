//
//  RNTapdaqSharedController.m
//  RNTapdaq
//
//  Created by Giedrius Mikoliunas on 2020-01-12.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNTapdaqSharedController.h"

@interface RNTapdaqSharedController ()

@end

@implementation RNTapdaqSharedController

static RNTapdaqSharedController *rnTapdaqSharedController = nil;

+ (RNTapdaqSharedController *)sharedController {
    if (rnTapdaqSharedController == nil) {
        rnTapdaqSharedController = [[super alloc] init];
    }
    return rnTapdaqSharedController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[Tapdaq sharedSession] setDelegate:self];
        self.nativeDelegates = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Note: This view does not load
}

- (void)tapDelegate:(NSString *)message {
    if (_delegate && [_delegate respondsToSelector:@selector(onControllerMessage:)]) {
        [_delegate onControllerMessage:message];
    }
}

- (void)addNativeDelegate:(id<AdNativeDelegate>)delegate ofPlacementTag:(NSString *)placement {
    if ([[_nativeDelegates allKeys] containsObject:placement]) {
        NSMutableArray *target = [_nativeDelegates objectForKey:placement];
        [target addObject:delegate];
        return;
    }
    NSMutableArray *newArr = [NSMutableArray new];
    [newArr addObject:delegate];
    [_nativeDelegates setObject:newArr forKey:placement];
}

- (void)informNativeDelegate:(TDAdRequest *)adRequest {
    TDNativeAdRequest *nativeAdRequest = (TDNativeAdRequest *)adRequest;
    NSMutableArray<id<AdNativeDelegate>> *delegates = [_nativeDelegates objectForKey:adRequest.placement.tag];
    if (!delegates || [delegates count] == 0) {
        NSLog(@"Error! No delegates");
        return;
    }
    id<AdNativeDelegate> delegate = [delegates objectAtIndex:0];
    if (delegate && [delegate respondsToSelector:@selector(onNativeAd:)]) {
        [delegate onNativeAd:nativeAdRequest];
    }
    [delegates removeObjectAtIndex:0];
}

- (void)informNativeDelegate:(TDNativeAdRequest *)adRequest error:(TDError *)error {
    TDNativeAdRequest *nativeAdRequest = (TDNativeAdRequest *)adRequest;
    NSMutableArray<id<AdNativeDelegate>> *delegates = [_nativeDelegates objectForKey:adRequest.placement.tag];
    if (!delegates || [delegates count] == 0) {
        NSLog(@"Error! No delegates");
        return;
    }
    id<AdNativeDelegate> delegate = [delegates objectAtIndex:0];
    if (delegate && [delegate respondsToSelector:@selector(onNativeAd:)]) {
        [delegate onNativeAd:nativeAdRequest didFailToLoadWithError:error];
    }
    [delegates removeObjectAtIndex:0];
}

- (BOOL)isInitialized {
    return [[Tapdaq sharedSession] isInitialised];
}

- (void)initializeWithAppId:(NSString *)appId clientKey:(NSString *)clientKey properties:(TDProperties *)properties promise:(RNPromise *)promise {
    _initializationPromise = promise;
    [[Tapdaq sharedSession] setApplicationId:appId clientKey:clientKey properties:properties];
}

- (void)loadInterstitial:(NSString *)placement withPromise:(RNPromise *)promise {
    _adLoadPromise = promise;
    [[Tapdaq sharedSession] loadInterstitialForPlacementTag:placement delegate:self];
}

- (void)showInterstitial:(NSString *)placement withPromise:(RNPromise *)promise {
    _adDisplayPromise = promise;
    [[Tapdaq sharedSession] showInterstitialForPlacementTag:placement];
}

- (void)loadRewardedVideo:(NSString *)placement withPromise:(RNPromise *)promise {
    _adLoadPromise = promise;
    [[Tapdaq sharedSession] loadRewardedVideoForPlacementTag:placement delegate:self];
}

- (void)showRewardedVideo:(NSString *)placement promise:(RNPromise *)promise {
  _adDisplayPromise = promise;
    [[Tapdaq sharedSession] showRewardedVideoForPlacementTag:placement];
}

- (void)loadNativeAd:(NSString *)placement {
    [[Tapdaq sharedSession] loadNativeAdInViewController:self placementTag:placement options:TDMediatedNativeAdOptionsAdChoicesTopLeft delegate:self];
}

- (void)presentDebugViewController {
    [[Tapdaq sharedSession] presentDebugViewController];
}

- (BOOL)isInterstitialReadyForPlacementTag:(NSString *)placementTag {
    return [[Tapdaq sharedSession] isInterstitialReadyForPlacementTag:placementTag];
}

- (BOOL)isRewardedVideoReadyForPlacementTag:(NSString *)placementTag {
    return [[Tapdaq sharedSession] isRewardedVideoReadyForPlacementTag:placementTag];
}

- (void)setConsentGiven:(BOOL)value {
    [[Tapdaq sharedSession] setIsConsentGiven:value];
}

- (void)setIsAgeRestrictedUser:(BOOL)value {
    [[Tapdaq sharedSession] setIsAgeRestrictedUser:value];
}

- (void)setUserSubjectToGDPR:(BOOL)value {
    [[Tapdaq sharedSession] setUserSubjectToGDPR:value ? TDSubjectToGDPRYes : TDSubjectToGDPRNo];
}

- (void)setUserId:(NSString *)userId {
    [[Tapdaq sharedSession] setUserId:userId];
}

- (void)didLoadConfig {
    [self tapDelegate:@"Tapdaq initialized"];
    [_initializationPromise resolve];
}

- (void)didFailToLoadConfigWithError:(NSError *)error {
    [self tapDelegate:error.localizedDescription];
    [_initializationPromise reject:error];
}

- (void)didLoadAdRequest:(TDAdRequest *)adRequest {
    [self tapDelegate:@"Ad did load"];
    if (adRequest.placement.adTypes == TDAdTypeMediatedNative) {
        [self informNativeDelegate:adRequest];
        return;
    }
    [_adLoadPromise resolve];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToLoadWithError:(TDError *)error {
    if (adRequest.placement.adTypes == TDAdTypeMediatedNative) {
        [self informNativeDelegate:adRequest error:error];
        return;
    }
    [self tapDelegate:error.localizedDescription];
    [_adLoadPromise reject:error];
}

- (void)didDisplayAdRequest:(TDAdRequest *)adRequest {
    [self tapDelegate:@"Ad did display"];
    if (adRequest.placement.adTypes == TDAdTypeMediatedNative) return;
    [_adDisplayPromise resolve];
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToDisplayWithError:(TDError *)error {
    [self tapDelegate:error.localizedDescription];
    [_adDisplayPromise reject:error];
}

- (void)didCloseAdRequest:(TDAdRequest *)adRequest {
    [self tapDelegate:@"Ad Closed"];
}

- (void)didClickAdRequest:(TDAdRequest *)adRequest {
    [self tapDelegate:@"Ad Clicked"];
}

- (void)adRequest:(TDAdRequest *)adRequest didValidateReward:(TDReward *)reward {
    if (_delegate && [_delegate respondsToSelector:@selector(onRedeem:reward:)]) {
        [_delegate onRedeem:adRequest reward:reward];
    }
}

- (void)adRequest:(TDAdRequest *)adRequest didFailToValidateReward:(TDReward *)reward {
    if (_delegate && [_delegate respondsToSelector:@selector(onRedeemFailed:didFailToValidateReward:)]) {
        [_delegate onRedeemFailed:adRequest didFailToValidateReward:reward];
    }
}

@end
