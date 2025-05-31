local shared = require(script._shared)
local ERR_NOT_WANTED_TYPE = shared.ERR_NOT_WANTED_TYPE
local ERR_UNKNOWN_TYPE = "Unknown type %*"

local METADATA = '__iizutype'

local TYPE_TABLE = 'table'
local TYPE_STRING = 'string'

local IizuType = { }
local schema = { }
local shadow = { __index = schema,
      __type = 'IizuType',
      __tostring = function ( self: IizuType )
            return rawget(self, METADATA).name
      end }

local List = { }


do -- Body

      local __queue_free = function ( self: any ): ( )
            setmetatable(self, nil)
            table.clear(self)
            table.freeze(self)
      end

      -- Creates a new Iizutype from a simple `data` dictionary. Returns
      -- `true` if it was successful.
      function IizuType.new ( data: { name: string, class: any, schema: any, shadow: any } ) : boolean
            data.class [METADATA] = { name = data.name, schema = data.schema, shadow = data.shadow }
            schema.__queue_free = __queue_free

            setmetatable(data.class, shadow)
            table.freeze(data.class)
            List [data.name] = data.class
            return true
      end


      -- Returns `true` if `obj` is an IizuType.
      function IizuType.Is ( obj: any ): boolean
            return typeof(obj) == 'table' and getmetatable(obj) == shadow
      end
      
      -- Returns `true` if `obj` is of a `type`.
      function IizuType.IsA ( obj: any, type: string )
            assert(typeof(type) == TYPE_STRING, string.format(ERR_NOT_WANTED_TYPE, TYPE_STRING, typeof(type)))
            assert(List[type] ~= nil, string.format(ERR_UNKNOWN_TYPE, type) )
            return List [type].Is(obj)
      end
      
      function IizuType.typeof ( obj: any )
            for type, data in List do
                  if data:Is (obj) then return type end
            end
            error(string.format(ERR_UNKNOWN_TYPE, 'could not identify as IizuType'))
      end

end

do -- Schema
      
      function schema.Is ( self: IizuType, obj: any ) : boolean
            return typeof(obj) == TYPE_TABLE and getmetatable(obj) == rawget(self, METADATA).shadow
      end
      
      
      function schema.schemaSet ( self: IizuType, var: any, val: any ) : ( )
            rawget(self, METADATA).schema [var] = val
      end
      
      function schema.schemaGet ( self: IizuType, var: any ) : ( )
            return rawget(self, METADATA).schema [var]
      end

end

export type IizuType = {
      Is : ( self: IizuType, obj: any ) -> boolean,

      SchemaSet : ( self: IizuType, var: any, val: any ) -> ( ),
      SchemaGet : ( self: IizuType, var: any ) -> ( )
}

table.freeze(IizuType)
return IizuType