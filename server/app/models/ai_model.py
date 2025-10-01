from sqlalchemy import Column, Integer, String, Float, Boolean, TIMESTAMP, func
from sqlalchemy import UniqueConstraint
from ..database import Base
class AIModel(Base):
    __tablename__ = "aimodel"

    model_id = Column(Integer, primary_key=True, autoincrement=True)
    model_name = Column(String(255), nullable=False)
    version = Column(String(50), nullable=False)
    trained_at = Column(TIMESTAMP, nullable=False)
    accuracy = Column(Float, nullable=False)
    is_active = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, server_default=func.now())

    __table_args__ = (UniqueConstraint("model_name", "version", name="unique_model_version"),)
