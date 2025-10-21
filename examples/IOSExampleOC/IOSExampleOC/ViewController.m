//
//  ViewController.m
//  IOSExampleOC
//
//  Created by VeryOauthSDK on 2025/10/17.
//

#import "ViewController.h"
#import <VeryOauthSDK/VeryOauthSDK-Swift.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"VeryOauthSDK Demo (CocoaPods)";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
}

- (void)setupUI {
    // Create result label
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    resultLabel.text = @"Authentication result will appear here";
    resultLabel.textColor = [UIColor systemGrayColor];
    resultLabel.font = [UIFont systemFontOfSize:14];
    resultLabel.numberOfLines = 0;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.backgroundColor = [UIColor systemGray6Color];
    resultLabel.layer.cornerRadius = 8;
    resultLabel.clipsToBounds = YES;
    self.resultLabel = resultLabel;
    [self.view addSubview:resultLabel];
    
    // Create authentication button
    UIButton *authButton = [UIButton buttonWithType:UIButtonTypeSystem];
    authButton.translatesAutoresizingMaskIntoConstraints = NO;
    [authButton setTitle:@"Start OAuth Authentication" forState:UIControlStateNormal];
    [authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    authButton.backgroundColor = [UIColor systemBlueColor];
    authButton.layer.cornerRadius = 12;
    authButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [authButton addTarget:self action:@selector(authButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.authButton = authButton;
    [self.view addSubview:authButton];
    
    // Create activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    // Setup constraints
    [NSLayoutConstraint activateConstraints:@[
        // Result label constraints
        [resultLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [resultLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [resultLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [resultLabel.heightAnchor constraintGreaterThanOrEqualToConstant:100],
        
        // Authentication button constraints
        [authButton.topAnchor constraintEqualToAnchor:resultLabel.bottomAnchor constant:40],
        [authButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [authButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [authButton.heightAnchor constraintEqualToConstant:50],
        
        // Activity indicator constraints
        [activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [activityIndicator.topAnchor constraintEqualToAnchor:authButton.bottomAnchor constant:30]
    ]];
}

- (void)authButtonTapped:(UIButton *)sender {
    [self startAuthentication];
}

- (void)startAuthentication {
    [self.activityIndicator startAnimating];
    self.authButton.enabled = NO;
    
    self.resultLabel.text = @"Starting authentication...";
    self.resultLabel.textColor = [UIColor systemBlueColor];
    
    // Create OAuth configuration with minimal required parameters
    OAuthConfig *config = [[OAuthConfig alloc] initWithClientId:@"veros_145b3a8f2a8f4dc59394cbbd0dd2a77f"
                                                   redirectUri:@"https://veros-web-oauth-demo.vercel.app/callback"
                                                      userId:@"vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"];
                       
    // Get the SDK instance
    VeryOauthSDK *sdk = [VeryOauthSDK shared];
    
        
    // Start authentication
    [sdk authenticateWithConfig:config
        presentingViewController:self
                       callback:^(OAuthResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleAuthenticationResult:result];
        });
    }];
}

- (void)handleAuthenticationResult:(OAuthResult *)result {
    [self.activityIndicator stopAnimating];
    self.authButton.enabled = YES;
    
    if ([result isKindOfClass:[Success class]]) {
        Success *success = (Success *)result;
        self.resultLabel.text = [NSString stringWithFormat:@"✅ Authentication successful!\n\nToken: %@\nState: %@", 
                                success.token, success.state ?: @"N/A"];
        self.resultLabel.textColor = [UIColor systemGreenColor];
    } else if ([result isKindOfClass:[Failure class]]) {
        Failure *failure = (Failure *)result;
        self.resultLabel.text = [NSString stringWithFormat:@"❌ Authentication failed:\n%@", 
                                failure.error.localizedDescription];
        self.resultLabel.textColor = [UIColor systemRedColor];
    } else if ([result isKindOfClass:[Cancelled class]]) {
        self.resultLabel.text = @"⚠️ Authentication cancelled by user";
        self.resultLabel.textColor = [UIColor systemOrangeColor];
    }
}

@end
