from sqlalchemy import event
from .db_dump import trigger_dump_update


def setup_database_events():
    """
    Attach model-level event listeners for insert, update, delete operations
    to trigger database dump updates.
    """
    from ..models.user_model import User
    from ..models.usersession_model import UserSession
    from ..models.vehicle_model import Vehicle

    tracked_models = [User, UserSession, Vehicle]

    # Event listeners
    def after_insert(mapper, connection, target):
        if isinstance(target, tuple(tracked_models)):
            trigger_dump_update()

    def after_update(mapper, connection, target):
        if isinstance(target, tuple(tracked_models)):
            trigger_dump_update()

    def after_delete(mapper, connection, target):
        if isinstance(target, tuple(tracked_models)):
            trigger_dump_update()

    # Attach listeners to each tracked model
    for model in tracked_models:
        event.listen(model, 'after_insert', after_insert)
        event.listen(model, 'after_update', after_update)
        event.listen(model, 'after_delete', after_delete)

    print("[DB EVENTS] Database event listeners attached for dump updates.")
