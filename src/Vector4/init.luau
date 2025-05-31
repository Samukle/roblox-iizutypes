local Vector4 = { }
local schema = { }
local shadow = { __index = schema, __type = 'Vector4' }

local shared = require(script.Parent._shared)
local ERR_NOT_WANTED_TYPE = shared.ERR_NOT_WANTED_TYPE
local ERR_READ_ONLY = shared.ERR_READ_ONLY

local TYPE_VECTOR3 = 'Vector3'
local TYPE_VECTOR4 = 'Vector4'
local TYPE_NUMBER = 'number'
local TYPE_TABLE = 'table'
local COMP0, COMP1, COMP2, COMP3 =
      'X', 'Y', 'Z', 'A'

do -- Body

      -- Creates a Vector4 where V = (X, Y, Z, A)
      function Vector4.new (
            x: number|Vector3|Vector4?, y: number?, z: number?, a: number?
      ) : Vector4
            if Vector4.Is(x) then
                  a = x [COMP3]
                  z = x [COMP2]
                  y = x [COMP1]
                  x = x [COMP0]
            end
            if typeof(x) == TYPE_VECTOR3 then
                  return Vector4.fromVector3(x, y)
            end

            local vars = { x,y,z,a }
            for _, var in vars do
                  assert(typeof(var) == TYPE_NUMBER or var == nil, string.format(ERR_NOT_WANTED_TYPE, TYPE_NUMBER, typeof(var)))
            end
            vars = nil
            local this = {
                  [COMP0] = x or 0,
                  [COMP1] = y or 0,
                  [COMP2] = z or 0,
                  [COMP3] = a or 0
            }

            setmetatable(this, shadow)
            return this
      end

      -- Creates a Vector4 based out of a Vector3 and an alpha component.
      function Vector4.fromVector3 ( x: Vector3, a: number? ): Vector4
            return Vector4.new(x.X, x.Y, x.Z, a)
      end

      
      -- Returns the Magnitude component of the Vector4 `x`
      function Vector4.GetMagnitude ( x: Vector4 ) : number
            assert(Vector4.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR4, typeof(x)))
            return ((x.X)^2 + (x.Y)^2 + (x.Z)^2 + (x.A)^2)^0.5
      end

      -- Returns the Unit component of the Vector4 `x`
      function Vector4.GetUnit ( x: Vector4 ) : Vector4
            assert(Vector4.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR4, typeof(x)))
            return x / ((x.X)^2 + (x.Y)^2 + (x.Z)^2 + (x.A)^2)^0.5
      end


      -- Returns a Vector3 with the XYZ components
      function Vector4.ToVector3 ( x: Vector4 ) : Vector3
            assert(Vector4.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR4, typeof(x)))
            return x:ToVector3()
      end

end

do -- Schema

      function schema.GetComponents( self: Vector4 ): (number, number, number, number)
            return rawget(self, COMP0), rawget(self, COMP1), rawget(self, COMP2), rawget(self, COMP3)
      end

      function schema.ToVector3( self: Vector4 ): Vector3
            return Vector4.ToVector3(self)
      end

      function schema.Lerp ( x: Vector4, y: Vector4, a: number ): Vector4
            assert(Vector4.Is(x), string.format(ERR_NOT_WANTED_TYPE, TYPE_VECTOR4, typeof(x)))
            local v4 = Vector4.new(x)
            for i, j in v4:GetComponents() do
                  v4[i] = j + (y[i] - j) * a
            end
            return v4
      end

end

do -- Shadow set-up

      function shadow.__index ( self: Vector4, var: string ): any
            if var == "Unit" then
                  return Vector4.GetUnit(self)
            elseif var == "Magnitude" then
                  return Vector4.GetMagnitude(self)
                  
            elseif var == "UnitXYZ" then
                  return self:ToVector3().Unit
            elseif var == "MagnitudeXYZ" then
                  return self:ToVector3().Magnitude

            end
      end

      function shadow.__newindex ( _: Vector4, var: string, val: any ): ( )
            return error(string.format(ERR_READ_ONLY, var, val))
      end

      function shadow.__unm( self: Vector4 ): Vector4
            return Vector4.new ( -self.X, -self.Y, -self.Z, -self.A )
      end

      function shadow.__add( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if Vector4.Is(val) then
                  return Vector4.new ( self.X+val.X, self.Y+val.Y, self.Z+val.Z, self.A+val.A )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X+val.X, self.Y+val.Y, self.Z+val.Z, self.A )
            end
      end
      
      function shadow.__sub( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if Vector4.Is(val) then
                  return Vector4.new ( self.X-val.X, self.Y-val.Y, self.Z-val.Z, self.A-val.A )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X-val.X, self.Y-val.Y, self.Z-val.Z, self.A )
            end
      end

      function shadow.__mul( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if typeof(val) == TYPE_NUMBER then
                  return Vector4.new ( self.X*val, self.Y*val, self.Z*val, self.A*val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X*val.X, self.Y*val.Y, self.Z*val.Z, self.A )
            elseif Vector4.Is(val) then
                  return Vector4.new ( self.X*val.X, self.Y*val.Y, self.Z*val.Z, self.A*val.A )
            end
      end

      function shadow.__div( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if typeof(val) == TYPE_NUMBER then
                  return Vector4.new ( self.X/val, self.Y/val, self.Z/val, self.A/val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X/val.X, self.Y/val.Y, self.Z/val.Z, self.A )
            elseif Vector4.Is(val) then
                  return Vector4.new ( self.X/val.X, self.Y/val.Y, self.Z/val.Z, self.A/val.A )
            end
      end

      function shadow.__idiv( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if typeof(val) == TYPE_NUMBER then
                  return Vector4.new ( self.X//val, self.Y//val, self.Z//val, self.A//val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X//val.X, self.Y//val.Y, self.Z//val.Z, self.A )
            elseif Vector4.Is(val) then
                  return Vector4.new ( self.X//val.X, self.Y//val.Y, self.Z//val.Z, self.A//val.A )
            end
      end

      function shadow.__pow( self: Vector4, val: number|Vector3|Vector4 ): Vector4
            if typeof(val) == TYPE_NUMBER then
                  return Vector4.new ( self.X^val, self.Y^val, self.Z^val, self.A^val )
            elseif typeof(val) == TYPE_VECTOR3 then
                  return Vector4.new ( self.X^val.X, self.Y^val.Y, self.Z^val.Z, self.A )
            elseif Vector4.Is(val) then
                  return Vector4.new ( self.X^val.X, self.Y^val.Y, self.Z^val.Z, self.A^val.A )
            end
      end

end

Vector4.zero = Vector4.new( 0,0,0,0 )
Vector4.one  = Vector4.new( 1,1,1,1 )

export type Vector4 = {
      X: number,
      Y: number,
      Z: number,
      A: number,

      Unit: Vector4,
      UnitXYZ: Vector3,
      Magnitude: number,
      MagnitudeXYZ: number,

      ToVector3: ( self: Vector4 ) -> ( Vector3, Vector3 ),
      ToVector3XYZ: ( self: Vector4 ) -> ( Vector3 ),
      ToVector3WHD: ( self: Vector4 ) -> ( Vector3 ),
      Lerp: ( x: Vector4, y: Vector4, a: number ) -> Vector4,
}

require(script.Parent).new { name = 'Vector4', class = Vector4, schema = schema, shadow = shadow }
return Vector4