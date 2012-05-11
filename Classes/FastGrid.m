/*
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

//
// A class that transforms a texture into a grid
//

#import "FastGrid.h"

@interface FastGrid (Private)

-(void)calculateVertexPoints;

@end

@implementation FastGrid

+(id) gridWithTexture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

-(id)initWithTexture:(CCTexture2D*)texture
{
	if ( (self = [super init] ) )
	{
		self.texture = texture;
		sprite_ = [[CCSprite alloc] initWithTexture:texture];
	}
	
	return self;
}

- (void) dealloc
{
	[sprite_ release];
	[texture_ release];
	[fastGrid_ release];
		
	[super dealloc];
}


-(void)draw
{
	if( fastGrid_ && fastGrid_.active ) {

		ccGLBindTexture2D( [texture_ name]);
		
		[fastGrid_ blit];

	} else {
		[sprite_ draw];
	}
}

// override "slow grid"
-(CCGridBase*) grid
{
	return fastGrid_;
}

-(void) setGrid:(CCGridBase*)grid
{
	[grid setIsTextureFlipped:YES];
	[fastGrid_ release];
	fastGrid_ = [grid retain];
	[fastGrid_ setTexture:texture_];
}

// set texture into fastgrid if a new texture is set
-(void) setTexture:(CCTexture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	[fastGrid_ setTexture:texture_];
}

-(CCTexture2D*) texture
{
	return texture_;
}
@end
