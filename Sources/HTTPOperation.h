#import <Foundation/Foundation.h>




@protocol HTTPOperationAuthenticationDelegate;




@interface HTTPOperation : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	id _target;
	SEL _action;
	NSThread* _targetTherad;
	NSMutableData* _recievedData;
	
	NSURLConnection* _connection;
	
	BOOL _canceled;
}



// these are object (NS is object)
@property (strong) NSURLRequest* request;
@property (strong, readonly) NSData* recievedData;
@property (strong, readonly) NSError* error;

@property (readonly) BOOL isCanceled;




// assign is not object
@property (assign) id<HTTPOperationAuthenticationDelegate> authenticationDelegate;






// 3 Methods that takes parameters
// Setter and Getters????
- (id)initWithRequest:(NSURLRequest*)request target:(id)target finishedAction:(SEL)action;

- (void)start;

- (void)cancel;

- (void)finishWithError:(NSError *)error;

@end






@protocol HTTPOperationAuthenticationDelegate <NSObject>

@required

- (BOOL)httpOperation:(HTTPOperation*)operation canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)httpOperation:(HTTPOperation*)operation didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end