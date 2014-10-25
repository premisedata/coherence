//
//  Property.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#ifndef __MGResourceManager__Property__
#define __MGResourceManager__Property__

#include <iostream>
#include "Component.h"

namespace mg { namespace wsdl {
    
    /**
     Represents an abstract binding in wsdl 2.0
     
     */
    class Property : public mg::wsdl::Component {
        
    public:
        // Construction
        Property(std::string name);
        ~Property();
        
    private:
        
        
    };
    
} } // mg::wsdl

#endif /* defined(__MGResourceManager__Property__) */
