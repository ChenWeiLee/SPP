//
//  ViewController.m
//  SPP
//
//  Created by Justin on 13/8/6.
//  Copyright (c) 2013年 Justin. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [CM scanForPeripheralsWithServices:nil options:NULL];
    [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
   /* NSArray	*uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"180D"], nil];
    [CM scanForPeripheralsWithServices:uuidArray options:optind];
    */

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
    BOOL isWork=FALSE;
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            /*if (connectedPeripheral!=NULL){
                [CM cancelPeripheralConnection:connectedPeripheral];
            }*/
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            isWork=TRUE;
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    
    NSLog(@"%@",nsmstring);
  //  [delegate didUpdateState:isWork message:nsmstring getStatus:cManager.state];
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
    [nsmstring appendString:@"Peripheral Info:"];
    [nsmstring appendFormat:@"NAME: %@\n",peripheral.name];
    [nsmstring appendFormat:@"RSSI: %@\n",RSSI];
    
    if (peripheral.isConnected){
        [nsmstring appendString:@"isConnected: connected"];
    }else{
        [nsmstring appendString:@"isConnected: disconnected"];
    }
    NSLog(@"adverisement:%@",advertisementData);
    [nsmstring appendFormat:@"adverisement:%@",advertisementData];
    [nsmstring appendString:@"didDiscoverPeripheral\n"];
    NSLog(@"aam %@",nsmstring);
    NSLog(@"ccm %d",peripheral.services.count);
  
    
    [CM connectPeripheral:peripheral options:NULL];

    
}

- (void) scanTimeout:(NSTimer*)timer
{
    if (CM!=NULL){
      //  [CM stopScan];
    }else{
        NSLog(@"CM is Null!");
    }
    NSLog(@"11111123%@",CM);
    NSLog(@"scanTimeout");
  //  [self centralManager:CM didDiscoverPeripheral:nil advertisementData:nil RSSI:nil];
}
- (void) connect:(CBPeripheral*)peripheral
{
    
	if (![peripheral isConnected]) {
		[CM connectPeripheral:peripheral options:nil];
        NSLog(@"11111123sdfdsfdsfsfsfsf");

      //  connectedPeripheral=peripheral;
	}
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connect To Peripheral with name: %@\nwith UUID:%@\n",peripheral.name,CFUUIDCreateString(NULL, peripheral.UUID));
    peripheral.delegate=self;
    [peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
 //   NSLog(@"%@",peripheral);
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:\n");
    if( peripheral.UUID == NULL  ) {
        
        NSLog(@" peripheral.UUID == NULL  !!!!!!!!!!!");
        return; // zach ios6 added
    }
    if (!error) {
        NSLog(@"====%@\n",peripheral.name);
        NSLog(@"=========== %d of service for UUID %@ ===========\n",peripheral.services.count,CFUUIDCreateString(NULL,peripheral.UUID));
        
        for (CBService *p in peripheral.services){
            NSLog(@"Service found with UUID: %@\n", p.UUID);
            [peripheral discoverCharacteristics:nil forService:p];
        }
        
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !\n");
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
    NSLog(@"=========== Service UUID %@ ===========\n",[self CBUUIDToString:service.UUID]);
    if (!error) {
        NSLog(@"=========== %d Characteristics of service ",service.characteristics.count);
        
        for(CBCharacteristic *c in service.characteristics){
            
            NSLog(@" %@ \n",[ self CBUUIDToString:c.UUID]);
            //  CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if(service.UUID == NULL || s.UUID == NULL) return; // zach ios6 added
            
            
            //Register notification註冊通知
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
                
            {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
                {
                    [self notification:service.UUID characteristicUUID:c.UUID peripheral:peripheral on:YES];
                    NSLog(@"registered notification 2A37");
                }
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
                {
                    [self notification:service.UUID characteristicUUID:c.UUID peripheral:peripheral on:YES];
                    NSLog(@"registered notification 2A38");
                }
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
                {
                    [self notification:service.UUID characteristicUUID:c.UUID peripheral:peripheral on:YES];
                    NSLog(@"registered notification 2A39");
                }
                
            }
            
        }
        NSLog(@"=== Finished set notification ===\n");
        
        
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\n");
        
    }
    if([self compareCBUUID:service.UUID UUID2:s.UUID]) {//利用此來確定整個流程都結束後才能設定通知
       // [delegate didConnected:peripheral error:error];
        NSLog(@"=== Finished discovering characteristics ===\n");
        //全部服務都讀取完畢時才能使用！
    }
    
}

//註冊通知function
//將Characteristic的Point傳入並設定setNotifyValue:on就完成註冊通知，之後如果有更新資料時就會引發didUpdateValueForCharacteristic Delegate，再進行資料處理。
-(void) notification:(CBUUID *) serviceUUID characteristicUUID:(CBUUID *)characteristicUUID peripheral:(CBPeripheral *)p on:(BOOL)on {
    
    CBService *service = [self getServiceFromUUID:serviceUUID p:p];
    if (!service) {
        if (p.UUID == NULL) return; // zach ios6 addedche
        NSLog(@"Could not find service with UUID on peripheral with UUID \n");
        return;
    }
    CBCharacteristic *characteristic = [self getCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        if (p.UUID == NULL) return; // zach ios6 added
        NSLog(@"Could not find characteristic with UUID  on service with UUID  on peripheral with UUID\n");
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
    
}


-(CBService *) getServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    
    for (CBService* s in p.services){
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) getCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    
    for (CBCharacteristic* c in service.characteristics){
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

//整個didUpdateValueForCharacteristic在處理時請注意資料格式的解釋，往往是因為格式解釋錯誤才會得到不正確的資料。
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        if( (characteristic.value)  || !error )
        {
            
        }
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
    {
        //set refresh int
        uint8_t val = 1;
        NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
        [peripheral writeValue:valData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    
}
@end
