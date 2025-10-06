# app/utils/db_events.py
from sqlalchemy import event
from .db_dump import trigger_dump_update


def setup_database_events():
    """
    Attach model-level event listeners for insert, update, delete operations
    to trigger database dump updates.
    """

    # Import models here, inside the function, to avoid circular imports
    from ..models.user_model import User
    from ..models.usersession_model import UserSession
    from ..models.vehicle_model import Vehicle
    from ..models.notification_model import Notification

    tracked_models = [User, UserSession, Vehicle]

    def after_change(mapper, connection, target):
        if isinstance(target, tuple(tracked_models)):
            trigger_dump_update()

    for model in tracked_models:
        event.listen(model, 'after_insert', after_change)
        event.listen(model, 'after_update', after_change)
        event.listen(model, 'after_delete', after_change)

    print("[DB EVENTS] Database event listeners attached for dump updates.")
