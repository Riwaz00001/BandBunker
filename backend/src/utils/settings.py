from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config=SettingsConfigDict(env_file=".env",extra="ignore")
    CONNECTION:str
    SECRET_KEY:str
    ALGORITHM:str
    EXP_TIME:int
    supabase_url:str
    supabase_key:str
    bucket:str
settings=Settings()