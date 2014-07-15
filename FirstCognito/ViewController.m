//
//  ViewController.m
//  FirstCognito
//
//  Created by 河野 智遵 on 2014/07/15.
//  Copyright (c) 2014年 Jabaraster. All rights reserved.
//

#import "ViewController.h"
#import "AWSCore.h"
#import <AWSCognitoSync/Cognito.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // プロバイダの作成
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:@"195957709288"
                                                          identityPoolId:@"us-east-1:d54c9894-092f-49ac-970b-2797dd81a380"
                                                          unauthRoleArn:nil
                                                          authRoleArn:nil];
    
    // 設定
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    // 匿名ログイン
    [[credentialsProvider getIdentityId] continueWithSuccessBlock:^id(BFTask *task){
        NSString* cognitoId = credentialsProvider.identityId;
        NSLog(@"cognitoId: %@", cognitoId);
        [self launchCount];
        return nil;
    }];
}

- (void)launchCount
{
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataSet"];
    
    // 取得
    int value = [[dataset stringForKey:@"launchCount"] intValue];
    NSLog(@"launchCount : %d", value);
    
    // 削除(ローカルのみ)
    [dataset clear];
    
    // 保存
    [dataset setString:[NSString stringWithFormat:@"%d", value + 1] forKey:@"launchCount"];
    
    // 同期
    [[dataset synchronize] continueWithBlock:^id(BFTask *task) {
        if (task.isCancelled) {
            NSLog(@"同期キャンセル");
        } else if (task.error) {
            NSLog(@"同期エラー: %@",task.error);
        } else {
            NSLog(@"同期成功");
        }
        return nil;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
