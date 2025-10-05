module models.user;

/**
 * Represents a user in the system.
 */
class User
{
    private string _firstName;
    private string _lastName;

    this(string firstName, string lastName)
    {
        _firstName = firstName;
        _lastName = lastName;
    }

    @property string firstName() const
    {
        return _firstName;
    }

    @property string lastName() const
    {
        return _lastName;
    }

    @property string fullName() const
    {
        return _firstName ~ " " ~ _lastName;
    }
}



