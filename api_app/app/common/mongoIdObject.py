from bson import ObjectId
from bson import ObjectId

"""
MongoDB stores data as BSON. FastAPI encodes and decodes data as JSON strings. 
BSON has support for additional non-JSON-native data types, 
including ObjectId which can't be directly encoded as JSON. 
Because of this, we convert ObjectIds to strings before storing them as the _id.
"""

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")