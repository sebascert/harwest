from dataclasses import dataclass


@dataclass
class CodeforcesConfig:
    handle: str
    def from_dict(cls, data):
    """Recursively parse dictionaries into dataclass instances."""
    if isinstance(data, dict):
        fieldtypes = {f.name: f.type for f in cls.__dataclass_fields__.values()}
        return cls(**{
            key: from_dict(fieldtypes[key], value) if hasattr(fieldtypes[key], '__dataclass_fields__') else value
            for key, value in data.items()
        })
    elif isinstance(data, list):
        return [from_dict(cls.__args__[0], item) for item in data]  # For List[T]
    else:
        return data

