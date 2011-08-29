//
//  ChipmunkHelper.c
//  SapusTongue-iOS
//

//
// Functions taken from ChipmunkDemo source code
//

#include <stdio.h>

#include "chipmunk.h"

#define NO_POST_REMOVAL 1

#if NO_POST_REMOVAL

static void shapeFreeWrap( cpShape *shape, void *unused)
{
	cpShapeFree(shape);
}

static void constraintFreeWrap(cpConstraint *constraint, void *unused)
{
	cpConstraintFree(constraint);
}

static void bodyFreeWrap(cpBody *body, void *unused)
{
	cpBodyFree(body);
}


// Safe and future proof way to remove and free all objects that have been added to the space.
void ChipmunkFreeSpaceChildren(cpSpace *space)
{
	// Must remove these BEFORE freeing the body or you will access dangling pointers.
	cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)shapeFreeWrap, space);
	cpSpaceEachConstraint(space, (cpSpaceConstraintIteratorFunc)constraintFreeWrap, space);
	
	cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)bodyFreeWrap, space);
}

#else

static void shapeFreeWrap(cpSpace *space, cpShape *shape, void *unused){
	cpSpaceRemoveShape(space, shape);
	cpShapeFree(shape);
}

static void postShapeFree(cpShape *shape, cpSpace *space){
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)shapeFreeWrap, shape, NULL);
}

static void constraintFreeWrap(cpSpace *space, cpConstraint *constraint, void *unused){
	cpSpaceRemoveConstraint(space, constraint);
	cpConstraintFree(constraint);
}

static void postConstraintFree(cpConstraint *constraint, cpSpace *space){
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)constraintFreeWrap, constraint, NULL);
}

static void bodyFreeWrap(cpSpace *space, cpBody *body, void *unused){
	cpSpaceRemoveBody(space, body);
	cpBodyFree(body);
}

static void postBodyFree(cpBody *body, cpSpace *space){
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)bodyFreeWrap, body, NULL);
}

// Safe and future proof way to remove and free all objects that have been added to the space.
void ChipmunkFreeSpaceChildren(cpSpace *space)
{
	// Must remove these BEFORE freeing the body or you will access dangling pointers.
	cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)postShapeFree, space);
	cpSpaceEachConstraint(space, (cpSpaceConstraintIteratorFunc)postConstraintFree, space);
	
	cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)postBodyFree, space);
}

#endif // ! NO_POST_REMOVAL