Musing: Actions
===============



Decoupling Actions Derived from Changes in Model
------------------------------------------------

It is preferred that if something would be derived from a change in the Model that it be derived from the source of that.  But, should something be wholely derived from the model, then what ever it eventually funnels into should never cycle back into the model, but rather flow out of the process graph through either a `port` or a `send`.

An example is the use of server API Credentials derived from a Server Model, the latter of which is itself stored in the App Model.
