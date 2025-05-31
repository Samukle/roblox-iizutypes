-- TODO@OPTIM Type checking
-- TODO@OPTIM Documentation

local iizutypes = require(script.Parent)

local FakeRandom = { }
local schema = { }
local shadow = { __index = schema, __type = 'FakeRandom' }

local shared = require(script.Parent._shared)
local ERR_NOT_WANTED_TYPE = shared.ERR_NOT_WANTED_TYPE
local ERR_READ_ONLY = shared.ERR_READ_ONLY


do -- Body
      
      function FakeRandom.new ( seed: number?, min: number?, max: number?, indexMin: number?, indexMax: number? )
            local generator = Random.new(seed)
            local this = {
                  Array = { },
                  Index = indexMin or 1,
                  IndexMin = indexMin or 1,
                  IndexMax = indexMax or 256,
                  Min = min,
                  Max = max
            }

            for i = math.floor(indexMin or 1), math.ceil(indexMax or 256), 1 do
                  this.Array [i] = generator:NextInteger(min or 0, max or 255)
            end

            setmetatable(this, shadow)
            return this
      end

end


do
      
      function schema:UpdateIndex ( add: number? )
            self.Index += add or 0
            if self.Index > self.IndexMax then
                  self.Index -= (self.IndexMax) * math.floor(add/self.IndexMax)
            elseif self.Index < self.IndexMin then
                  self.Index -= (self.IndexMin) * math.floor(add/self.IndexMin)
            end
            return self.Array [self.Index]
      end

      function schema:Next ( skip: number? )
            return self:UpdateIndex(1+(skip or 0))
      end
      
      function schema:Previous( skip: number? )
            return self:UpdateIndex(-1-(skip or 0))
      end

end


export type FakeRandom = {
      Array: { number },
      Index: number,
      IndexMax: number,
      IndexMin: number,
      Min: number,
      Max: number
}

iizutypes.new { name = 'FakeRandom', class = FakeRandom, schema = schema, shadow = shadow }

table.freeze(FakeRandom)
return FakeRandom