from dataclasses import dataclass


@dataclass
class CodeforcesConfig:
    handle: str
    api_key: str | None
    api_secret: str | None
