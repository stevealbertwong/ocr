#import "Client.h"
#import "ProcessingOperation.h"
#import "Task.h"
#import "ActivationInfo.h"
#import "NSString+Base64.h"

@implementation Client

@synthesize applicationID = _applicationID;
@synthesize password = _password;

@synthesize installationID = _installationID;

@synthesize delegate = _delegate;






- (id)init
{
	return [self initWithApplicationID:nil password:nil];
}



// Initialisers
// Initializer is an instance method

- (id)initWithApplicationID:(NSString *)applicationID password:(NSString *)password
{
	self = [super init];
	
	if (self) {
        
        //Setting up 2 instance variable for the parameteres that are passed in
		_applicationID = applicationID;
		_password = password;
	}
	
	return self;
}








//Anthenticate input credentials
- (NSString*)authString
{
	NSString *encodedCredentials = [[NSString stringWithFormat:@"%@:%@", self.applicationID, self.password] base64EncodedString];
	
	return [NSString stringWithFormat:@"Basic %@", encodedCredentials];
}









// THREE steps to Activate new installation of Device ID
// 1. Go to activationURL
// 2. Request response data
// 3. Create installationID from response data to activate installation of Device ID


- (NSString*)activateNewInstallation:(NSString*)deviceID
{
	NSString* installationID;
	
	NSURL* activationURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cloud.ocrsdk.com/activateNewInstallation?deviceId=%@", deviceID]];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:activationURL];
	[request setValue:[self authString] forHTTPHeaderField:@"Authorization"];
	
	NSError* error;
	
	NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:0 error:&error];
	
	if(error == nil) {
		ActivationInfo* info = [[ActivationInfo alloc] initWithData:responseData];
		installationID = info.installationID;
        // See ActivationInfo
	} else {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil, nil];
		
		[alert show];
	}
	
	return installationID;
}







// Default set to English 



- (void)processImage:(UIImage*)image withParams:(ProcessingParams*)params
{		
	// To test not nil (like optional)
    NSParameterAssert(image);
	
    
    
	NSURL* processingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cloud.ocrsdk.com/processImage?%@", [params urlString]]];
    
    
	
	NSMutableURLRequest* processingRequest = [NSMutableURLRequest requestWithURL:processingURL];
	
	[processingRequest setHTTPMethod:@"POST"];
	[processingRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[processingRequest setHTTPBody:UIImageJPEGRepresentation(image, 0.5)];
	
	[processingRequest setValue:[self authString] forHTTPHeaderField:@"Authorization"];
	
	HTTPOperation *uploadOperation = [[HTTPOperation alloc] initWithRequest:processingRequest 
																	 target:self 
															 finishedAction:@selector(uploadFinished:)];
	
	[uploadOperation setAuthenticationDelegate:self];
	
	[uploadOperation start];
}












- (void)uploadFinished:(HTTPOperation*)operation
{
	if (operation.error != nil) {
		if ([self.delegate respondsToSelector:@selector(client:didFailedWithError:)]) {
			[self.delegate client:self didFailedWithError:operation.error];
		}
	} else {
		if ([self.delegate respondsToSelector:@selector(clientDidFinishUpload:)]) {
			[self.delegate clientDidFinishUpload:self];
		}
		
		Task* task = [[Task alloc] initWithData:operation.recievedData];
		
		NSParameterAssert(task);
		NSParameterAssert(task.ID);
		
		NSURL* processingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://cloud.ocrsdk.com/getTaskStatus?taskId=%@", task.ID]];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:processingURL];
		
		[request setValue:[self authString] forHTTPHeaderField:@"Authorization"];
		
		ProcessingOperation *processingOperation = [[ProcessingOperation alloc] initWithRequest:request 
																						 target:self 
																				 finishedAction:@selector(processingFinished:)];
		[processingOperation setAuthenticationDelegate:self];
		
		[processingOperation start];
	}
}













- (void)processingFinished:(HTTPOperation*)operation
{
	if (operation.error != nil) {
		if ([self.delegate respondsToSelector:@selector(client:didFailedWithError:)]) {
			[self.delegate client:self didFailedWithError:operation.error];
		}
	} else {
		Task* task = [[Task alloc] initWithData:operation.recievedData];
		
		if ([self.delegate respondsToSelector:@selector(clientDidFinishProcessing:)]) {
			[self.delegate clientDidFinishProcessing:self];
		}
		
		NSParameterAssert(task);
		NSParameterAssert(task.downloadURL);
		
		NSURLRequest *request = [NSURLRequest requestWithURL:task.downloadURL];
		
		HTTPOperation *downloadOperation = [[ProcessingOperation alloc] initWithRequest:request 
																				 target:self 
																		 finishedAction:@selector(downloadFinished:)];

		[downloadOperation start];
	}
}

- (void)downloadFinished:(HTTPOperation*)operation
{
	if (operation.error != nil) {
		if ([self.delegate respondsToSelector:@selector(client:didFailedWithError:)]) {
			[self.delegate client:self didFailedWithError:operation.error];
		}
	} else if ([self.delegate respondsToSelector:@selector(client:didFinishDownloadData:)]) {
		[self.delegate client:self didFinishDownloadData:operation.recievedData];
	}
}










#pragma mark - HTTPOperationAuthenticationDelegate implementation

- (BOOL)httpOperation:(HTTPOperation *)operation canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return YES;
}

- (void)httpOperation:(HTTPOperation *)operation didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential* credential = [NSURLCredential credentialWithUser:self.applicationID
																 password:self.password
															  persistence:NSURLCredentialPersistenceForSession];
		
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge]; 
	}
}

@end
