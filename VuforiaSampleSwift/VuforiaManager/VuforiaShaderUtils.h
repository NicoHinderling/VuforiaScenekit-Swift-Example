//
//  VuforiaShaderUtils.h
//  VuforiaSampleSwift
//
//
//  Created by Andrew Mendez on 2017/02/18.
//  Copyright © 2017 Andrew Mendez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VuforiaShaderUtils : NSObject

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName
                      fragmentShaderFileName:(NSString*) fragmentShaderFileName;

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName
                        withVertexShaderDefs:(NSString *) vertexShaderDefs
                      fragmentShaderFileName:(NSString *) fragmentShaderFileName
                      withFragmentShaderDefs:(NSString *) fragmentShaderDefs;


@end
