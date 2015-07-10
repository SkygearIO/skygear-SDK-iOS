//
//  ODDownloadAssetOperation.m
//  Pods
//
//  Created by Kenji Pa on 7/7/15.
//
//

#import "ODDownloadAssetOperation.h"

#import "ODAsset_Private.h"
#import "ODOperation+OverrideLifeCycle.h"

@interface ODDownloadAssetOperation ()

@property (nonatomic, readwrite) ODAsset *asset;
@property (nonatomic, readwrite) NSURLSession *session;
@property (nonatomic, readwrite) NSURLSessionDownloadTask *task;

@end

@implementation ODDownloadAssetOperation

- (instancetype)initWithAsset:(ODAsset *)asset
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _asset = asset;
    }
    return self;
}

+ (instancetype)operationWithAsset:(ODAsset *)asset
{
    return [[self alloc] initWithAsset:asset];
}

#pragma mark - NSOperation

- (void)start
{
    if (self.cancelled || self.executing || self.finished) {
        return;
    }

    [self operationWillStart];

    [self setExecuting:YES];

    BOOL shouldObserveProgress = self.downloadAssetProgressBlock != nil;

    NSURLRequest *request = [self makeRequest];
    __weak typeof(self) weakSelf = self;
    self.task = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf handleCompletionWithLocation:location response:response error:error];

        if (shouldObserveProgress) {
            [strongSelf.task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) context:nil];
        }

        [strongSelf setExecuting:NO];
        [strongSelf setFinished:YES];

    }];

    if (shouldObserveProgress) {
        [self.task addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) options:0 context:nil];
    }

    [self.task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            NSURLSessionDownloadTask *task = object;

            if (task.countOfBytesExpectedToReceive != NSURLSessionTransferSizeUnknown) {
                self.downloadAssetProgressBlock(self.asset, task.countOfBytesReceived*1.0 / task.countOfBytesExpectedToReceive);
            }
        }
    }
}

#pragma mark - Other methods

- (NSURLRequest *)makeRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.asset.url];
    return request;
}

- (void)handleCompletionWithLocation:(NSURL *)location response:(NSURLResponse *)response error:(NSError *)error
{
    if (self.downloadAssetCompletionBlock) {
        NSData *data = nil;
        if (!error) {
            data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
        }
        self.downloadAssetCompletionBlock(_asset, data, error);
    }
}

@end
