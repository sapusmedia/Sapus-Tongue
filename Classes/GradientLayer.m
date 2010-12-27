//
//  GradientLayer.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 09/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import "GradientLayer.h"

// Simple Layer that lets you draw a gradient layer.
// The sky is drawn using this Layer.
// TIP:
//   . OpenGL Quads are very efficient.
//   . In this case, the whole sky is drawn with only one cheap OpenGL call without using Texture Memory
//   . Instead of having a big image of a solid or gradient color, you can use a Quad

@implementation GradientLayer

-(void) setBottomColor:(ccColor4B)colorb topColor:(ccColor4B)colort
{
	
	ccColor4B tmp;
	
	for( int i=0; i < sizeof(squareColors) / sizeof(squareColors[0]);i++ )
	{
		if(i < 8 ) {
			tmp = colorb;
		} else {
			tmp = colort;
		}
		
		if( i % 4 == 0 )
			squareColors[i] = tmp.r;
		else if( i % 4 == 1)
			squareColors[i] = tmp.g;
		else if( i % 4 ==2  )
			squareColors[i] = tmp.b;
		else
			squareColors[i] = tmp.a;
	}	
}

@end
