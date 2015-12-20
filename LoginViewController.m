//
//  LoginViewController.m
//  objcEventClient
//
//  Created by Maxwell, Eric on 11/24/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "EventService.h"
#import "MMProgressHUD.h"
#import "EventTableViewController.h"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess:) name:EVENTS_CALL_COMPLETED_WITH_RESULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginFailure:) name:EVENTS_CALL_FAILED_WITH_ERROR object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)login:(id)sender
{
    [MMProgressHUD showWithTitle:@"Login..."];
    
    LoginDto *loginDto = [[LoginDto alloc] init];
    loginDto.username = self.username.text;
    loginDto.password = self.password.text;
    EventService *service = [EventService sharedInstance];
    [service loginUsingLoginDto:loginDto];
}

- (void)goToEvents
{
    UINavigationController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventNavController"];
    [self presentViewController:newView animated:YES completion:nil];
}

#pragma mark - notification events
- (void)onLoginSuccess:(NSNotification*)notification
{
    [MMProgressHUD dismissWithSuccess:@"" title:@"" afterDelay:0.2];
    [self performSelector:@selector(goToEvents)
               withObject:nil afterDelay:0.4];
}

- (void)onLoginFailure:(NSNotification*)notification
{
    NSError *error = notification.object;
    NSLog(@"error %@", error);
    [MMProgressHUD dismissWithError:@"" title:@"Unable to Login" afterDelay:1.0];
}


@end
