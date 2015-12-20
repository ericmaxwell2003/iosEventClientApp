//
//  SignupViewController.m
//  objcEventClient
//
//  Created by Maxwell, Eric on 11/24/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

#import "SignupViewController.h"

#import "EventService.h"
#import "MMProgressHUD.h"

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;

@end

@implementation SignupViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationSuccess:) name:EVENTS_CALL_COMPLETED_WITH_RESULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegistrationFailure:) name:EVENTS_CALL_FAILED_WITH_ERROR object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)signup:(id)sender {
    [MMProgressHUD showWithTitle:@"Register..."];
    
    RegistrationDto *registrationDto = [[RegistrationDto alloc] init];
    registrationDto.name = self.name.text;
    registrationDto.email = self.email.text;
    registrationDto.username = self.username.text;
    registrationDto.password = self.password.text;
    EventService *service = [EventService sharedInstance];
    [service registerWithRegistrationDto:registrationDto];
}

-(void) goBackToLogin
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)alreadyMember:(id)sender {
    [self goBackToLogin];
}

#pragma mark - notification events
- (void)onRegistrationSuccess:(NSNotification*)notification
{
    [MMProgressHUD dismissWithSuccess:@"" title:@"" afterDelay:0.2];
    [self performSelector:@selector(goBackToLogin)
               withObject:nil afterDelay:0.4];
}

- (void)onRegistrationFailure:(NSNotification*)notification
{
    NSError *error = notification.object;
    NSLog(@"error %@", error);
    [MMProgressHUD dismissWithError:@"" title:@"Unable to Login" afterDelay:1.0];
}

@end
