
#import "NumberCodes.h"
#import <Foundation/Foundation.h>

static const char* NUMBERCODE_BOOL             = @encode(BOOL);
static const char* NUMBERCODE_CHAR             = @encode(char);
static const char* NUMBERCODE_DOUBLE           = @encode(double);
static const char* NUMBERCODE_FLOAT            = @encode(float);
static const char* NUMBERCODE_INT              = @encode(int);
static const char* NUMBERCODE_INTEGER          = @encode(NSInteger);
static const char* NUMBERCODE_LONG             = @encode(long);
static const char* NUMBERCODE_LONGLONG         = @encode(long long);
static const char* NUMBERCODE_SHORT            = @encode(short);
static const char* NUMBERCODE_UNSIGNEDCHAR     = @encode(unsigned char);
static const char* NUMBERCODE_UNSIGNEDINT      = @encode(unsigned int);
static const char* NUMBERCODE_UNSIGNEDINTEGER  = @encode(NSUInteger);
static const char* NUMBERCODE_UNSIGNEDLONG     = @encode(unsigned long);
static const char* NUMBERCODE_UNSIGNEDLONGLONG = @encode(unsigned long long);
static const char* NUMBERCODE_UNSIGNEDSHORT    = @encode(unsigned short);

const char* getNumberCode(NumberType type)
{
	switch(type)
	{
		default:
		case NUMBERTYPE_UNKNOWN:
			return NULL;
		
		case NUMBERTYPE_BOOL:
			return NUMBERCODE_BOOL;
		
		case NUMBERTYPE_CHAR:
			return NUMBERCODE_CHAR;
		
		case NUMBERTYPE_DOUBLE:
			return NUMBERCODE_DOUBLE;
			
		case NUMBERTYPE_FLOAT:
			return NUMBERCODE_FLOAT;
			
		case NUMBERTYPE_INT:
			return NUMBERCODE_INT;
			
		case NUMBERTYPE_INTEGER:
			return NUMBERCODE_INTEGER;
			
		case NUMBERTYPE_LONG:
			return NUMBERCODE_LONG;
			
		case NUMBERTYPE_LONGLONG:
			return NUMBERCODE_LONGLONG;
			
		case NUMBERTYPE_SHORT:
			return NUMBERCODE_SHORT;
			
		case NUMBERTYPE_UNSIGNEDCHAR:
			return NUMBERCODE_UNSIGNEDCHAR;
			
		case NUMBERTYPE_UNSIGNEDINT:
			return NUMBERCODE_UNSIGNEDINT;
			
		case NUMBERTYPE_UNSIGNEDINTEGER:
			return NUMBERCODE_UNSIGNEDINTEGER;
			
		case NUMBERTYPE_UNSIGNEDLONG:
			return NUMBERCODE_UNSIGNEDLONG;
			
		case NUMBERTYPE_UNSIGNEDLONGLONG:
			return NUMBERCODE_UNSIGNEDLONGLONG;
			
		case NUMBERTYPE_UNSIGNEDSHORT:
			return NUMBERCODE_UNSIGNEDSHORT;
	}
}

NumberType getNumberTypeForNSNumber(void*nsnumber)
{
	NSNumber*number = (NSNumber*)nsnumber;
	
	if(number==nil)
	{
		return NUMBERTYPE_UNKNOWN;
	}
	
	const char*type = [number objCType];
	
	if(strcmp(type, getNumberCode(NUMBERTYPE_BOOL))==0)
	{
		return NUMBERTYPE_BOOL;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_CHAR))==0)
	{
		return NUMBERTYPE_CHAR;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_DOUBLE))==0)
	{
		return NUMBERTYPE_DOUBLE;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_FLOAT))==0)
	{
		return NUMBERTYPE_FLOAT;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_INT))==0)
	{
		return NUMBERTYPE_INT;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_INTEGER))==0)
	{
		return NUMBERTYPE_INTEGER;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_LONG))==0)
	{
		return NUMBERTYPE_LONG;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_LONGLONG))==0)
	{
		return NUMBERTYPE_LONGLONG;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_SHORT))==0)
	{
		return NUMBERTYPE_SHORT;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDCHAR))==0)
	{
		return NUMBERTYPE_UNSIGNEDCHAR;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDINT))==0)
	{
		return NUMBERTYPE_UNSIGNEDINT;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDINTEGER))==0)
	{
		return NUMBERTYPE_UNSIGNEDINTEGER;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDLONG))==0)
	{
		return NUMBERTYPE_UNSIGNEDLONG;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDLONGLONG))==0)
	{
		return NUMBERTYPE_UNSIGNEDLONGLONG;
	}
	else if(strcmp(type, getNumberCode(NUMBERTYPE_UNSIGNEDSHORT))==0)
	{
		return NUMBERTYPE_UNSIGNEDSHORT;
	}
	return NUMBERTYPE_UNKNOWN;
}
