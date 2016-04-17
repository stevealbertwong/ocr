#import <Foundation/Foundation.h>
#import "HTTPOperation.h"
#import "ProcessingParams.h"

@protocol ClientDelegate;



// Headerfile
// Declaring a class, ClassName, SuperClass, Protocol
// NSObject is base class, if you dont need to derive from something
@interface Client : NSObject<HTTPOperationAuthenticationDelegate> {

}





//Public Properties /methods

@property (strong, nonatomic) NSString* applicationID;
@property (strong, nonatomic) NSString* password;

@property (strong, nonatomic) NSString* installationID;






// Using (assign) meaning no memory management involved 
@property (assign) id<ClientDelegate> delegate;

- (id)initWithApplicationID:(NSString*)applicationID password:(NSString*)password;

- (NSString*)activateNewInstallation:(NSString*)deviceID;
- (void)processImage:(UIImage*)image withParams:(ProcessingParams*)params;

@end

@protocol ClientDelegate <NSObject>





// Protocol has optional method, a class could choose to implement only if it needs to

@optional

- (void)clientDidFinishUpload:(Client*)sender;
- (void)clientDidFinishProcessing:(Client*)sender;
- (void)client:(Client*)sender didFinishDownloadData:(NSData*)downloadedData;
- (void)client:(Client*)sender didFailedWithError:(NSError*)error;

@end