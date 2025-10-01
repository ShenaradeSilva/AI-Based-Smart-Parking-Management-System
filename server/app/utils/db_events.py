# app/utils/db_events.py
from sqlalchemy import event
from .db_dump import trigger_dump_update
from ..database import SessionLocal


def setup_database_events():
    """
        Setup event listeners for database operations that should trigger dump updates
    """
    from ..models.user_model import User
    from ..models.vehicle_model import Vehicle

    # List of models that should trigger dump updates
    tracked_models = [User, Vehicle]

    def after_commit_listener(session):
        """
            This gets called after ANY successful commit
        """
        # Check if any tracked models were involved in this session
        for obj in session.dirty.union(session.new).union(session.deleted):
            if any(isinstance(obj, model) for model in tracked_models):
                trigger_dump_update()
                break           # Only trigger once per commit

    # Attach the event listener
    event.listen(SessionLocal, "after_commit", after_commit_listener)


# Alternative
def setup_specific_events():
    """
        Setup specific event listeners for insert, update, delete operations
    """
    from ..models.user_model import User
    from ..models.vehicle_model import Vehicle

    def after_insert(mapper, connection, target):
        """
            After any insert on tracked models
        """
        if isinstance(target, (User, Vehicle)):
            trigger_dump_update()

    def after_update(mapper, connection, target):
        """
            After any update on tracked models
            """
        if isinstance(target, (User, Vehicle)):
            trigger_dump_update()

    def after_delete(mapper, connection, target):
        """
            After any delete on tracked models
        """
        if isinstance(target, (User, Vehicle)): trigger_dump_update()

    # Attach event listeners
    for model in [User, Vehicle]:
        event.listen(model, 'after_insert', after_insert)
        event.listen(model, 'after_update', after_update)
        event.listen(model, 'after_delete', after_delete)
