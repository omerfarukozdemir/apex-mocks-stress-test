# Future Methods, Callouts & Callbacks - Apex Mocks

This code is from [the article discussing Apex future methods, callouts, and callbacks](https://www.jamessimone.net/blog/joys-of-apex/future-method-callout-callback/) in the ongoing Joys of Apex series. The following classes are part of this section:

- Callout
- Callback
- Callback_Tests
- HttpCallout
- HttpCallout_Tests
- RestMethod (enum class)
- TypeUtils

Because Callout is a simple wrapper, and HttpCallout becomes your one-stop-shop for API usage, you unlock a lot of power in your codebase by implementing these classes to do async work. Most of your time can be spent extending the Callback class for discrete use-cases, and testing just those classes. Callback could be easily extended, for example, to be an abstract class whose execute and callback methods ended up wrapping the Queueable interface _or_ the Batchable interface.

## Notes

There's an interesting Apex error that one encounters while trying to pass a `System.Type` to an object that is serialized - in this case, the Callout class. Despite the fact that Queueable classes in Apex are _also_ serialized when `System.enqueueJob` is called, the classic `Json.serialize` method is not Type-safe, for whatever reason. Luckily, both the Callout constructor and the Callback constructor can be kept typesafe by only initializing the class name string within the Callout class and then immediately constructing the Type again from the class name within the HttpCallout class.

The below is the Readme from the master branch, explaining a little bit more about how this library came to be:

## Introduction

FFLib was [publicized with some fanfare way back in 2014](https://code4cloud.wordpress.com/2014/05/09/simple-dependency-injection/):

> This approach even allows us to write DML free tests that never even touch the database, and consequently execute very quickly!

But is this claim ... true?

It was suggested on Reddit following the publication of my second blog post on [The Joys Of Apex](https://jamessimone.net/blog/) that I was "[doing it wrong](https://www.reddit.com/r/salesforce/comments/egrw71/the_joys_of_apex_mocking_dml_operations/)." I thought a lot about what [u/moose04](https://www.reddit.com/user/moose04/) was saying - perhaps it had been premature of me to dismiss what I saw as the same "creep spread" and Java boilerplate that I wasn't crazy about when I considered the merits of the built-in Salesforce stubbing methods. To be clear - it's still possible for that to be the case. That said, Salesforce is a platform that (I believe) thrives on the ability for developers to quickly test and iterate through theories. Why not use the very same platform we were discussing to stress test my implementation against the FFLib library?

## My methodology

1. Create a new salesforce instance ... I just [signed up](https://developer.salesforce.com/signup) for one and got my security token emailed to me.
2. Set up [DMC](https://github.com/kevinohara80/dmc) (if you want to easily run the tests from the command line)
3. Git cloned [fflib-apexmocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks).
4. Clean up all the junk - I just took the latest version of their classes and deleted the rest.
5. Added `Crud`, `Crud_Tests`, `CrudMock`, `CrudMock_Tests`, `ICrud`, `TypeUtils`, and `TestingUtils` from my private repo for testing.
6. Wrote some stress tests in `ApexMocksTests`.
7. Run `cp .envexample .env` and fill out your login data there.
8. Deployed it all using `yarn deploy` (you can toggle tests running using the RUN_TESTS flag in your .env file).
9. Used `yarn dmc test ApexMocks*` to run the tests.

## Result

I wasn't sure what to expect when writing the stress tests. I wanted to choose deliberately long-running operations to simulate what somebody could expect for:

- CPU intensive transactions, particularly those involving complicated calculations
- Batch processes / queueable tasks which process large numbers of records (which I would hazard to say is a fairly common use-case in the SFDC ecosystem).

Here's what I found (note - I ran the tests ten times before taking this screenshot):

![Test results](./apex-mocks-test-failure.JPG)

(Run 1 was off my console, here's the other results ...)

Run 2 (with LARGE_NUMBER set to 1 million):

| Library  | Test                                       | Test Time                           |
| -------- | ------------------------------------------ | ----------------------------------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 2.069s                              |
| fflib    | fflib_should_mock_dml_statements_update    | System.LimitException after 37.036s |

Run 3 (with LARGE_NUMBER set to 1 million):

| Library  | Test                                       | Test Time                          |
| -------- | ------------------------------------------ | ---------------------------------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 1.955s                             |
| fflib    | fflib_should_mock_dml_statements_update    | System.LimitException after 38.21s |

Run 4 (with LARGE_NUMBER set to 100,000):

| Library  | Test                                       | Test Time |
| -------- | ------------------------------------------ | --------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 0.295s    |
| fflib    | fflib_should_mock_dml_statements_update    | 9.585s    |

Run 5 (with LARGE_NUMBER set to 100,000):

| Library  | Test                                       | Test Time |
| -------- | ------------------------------------------ | --------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 0.208s    |
| fflib    | fflib_should_mock_dml_statements_update    | 9.655s    |

Run 6 (with LARGE_NUMBER set to 100,000):

| Library  | Test                                       | Test Time |
| -------- | ------------------------------------------ | --------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 1.835s    |
| fflib    | fflib_should_mock_dml_statements_update    | 16.639s   |

Run 7 (with LARGE_NUMBER set to 1 million):

| Library  | Test                                       | Test Time                        |
| -------- | ------------------------------------------ | -------------------------------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 5.703s                           |
| fflib    | fflib_should_mock_dml_statements_update    | System.LimitException at 20.543s |

Run 8 (with LARGE_NUMBER set to 100,000):

| Library  | Test                                       | Test Time |
| -------- | ------------------------------------------ | --------- |
| CrudMock | crudmock_should_mock_dml_statements_update | 1.823s    |
| fflib    | fflib_should_mock_dml_statements_update    | 16.694s   |

Run 9 (with LARGE_NUMBER set to 100,000):

| Library  | Test                                         | Test Time                           |
| -------- | -------------------------------------------- | ----------------------------------- |
| CrudMock | crudmock_should_mock_dml_statements_update   | 1.796s                              |
| fflib    | fflib_should_mock_dml_statements_update      | System.LimitException after 15.994s |
| CrudMock | crudmock_should_mock_multiple_crud_instances | 14.206s                             |
| fflib    | fflib_should_mock_multiple_crud_instances    | 18.292s (passed, somehow)           |

Run 10 (LARGE_NUMBER set to 100,000):

| Library  | Test                                         | Test Time                           |
| -------- | -------------------------------------------- | ----------------------------------- |
| CrudMock | crudmock_should_mock_dml_statements_update   | .225s                               |
| fflib    | fflib_should_mock_dml_statements_update      | 9.655s                              |
| CrudMock | crudmock_should_mock_multiple_crud_instances | 1.711s                              |
| fflib    | fflib_should_mock_multiple_crud_instances    | System.LimitException after 16.212s |

Seasoned testing vets will note that there is some "burn-in" when testing on the SFDC platform; similar to the SSMS's optimizer, Apex tends to optimize over time. One of the first times I ran the first two tests, `crudmock_should_mock_dml_statements` and `fflib_should_mock_dml_statements`, the fflib test failed after 38 seconds and the CrudMock test passed in 1.955s).

The only time I successfully observed the CrudMock singleton test failing was when the value for `LARGE_NUMBER` was bumped up to 1 million (and, to be fair, it also ran several times successfully at that load).

Of course, it isn't reasonable to expect that these tests are exactly mirroring testing conditions. What is reasonable to expect is that the more complicated your test setup, the longer things are going to take using the FFLib library. The reason for that is simple - their mocks / stubs utilize deep call stacks:

- handleMethodCall
- mockNonVoidMethod
- recordMethod
- recordMethod again (overloaded)

That's just for an absurdly simple mocking setup, mocking one method. Again, the more you need to utilize mocking in your tests (particularly if you are testing objects passing through multiple handlers / triggers), the greater the overhead of the library on influencing your overall test time will be.

Thanks!
