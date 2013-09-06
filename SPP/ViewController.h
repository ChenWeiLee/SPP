//
//  ViewController.h
//  SPP
//
//  Created by Justin on 13/8/6.
//  Copyright (c) 2013年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate>{
    CBCentralManager *CM;
    //id *delegate<>
}
//@property(assign, nonatomic) id<CBCentralManagerDelegate> delegate;


@end
