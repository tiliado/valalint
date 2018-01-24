namespace Test {

    /* Toplevel namespace - shift -1 */
    public void foo() {
        warning("Hello");
    }

public void bar(int foo) {
    switch (foo) {
        /* case - shift -1 */
        case 1:
            print(1);
            break;
        /* default - shift -1 */
        default:
            print(0);
            break;
    }

    /* &&, || - shift -1 */
    if (foo == 1
        || foo == 2
        && foo == 3) {
        print();
    } else {
    print();
    }

    printf("foo %d %d",
    1,
    2);
    print(print(
    1, 2));
}

} // namespace Test
