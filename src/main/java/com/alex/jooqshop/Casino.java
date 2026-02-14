import java.util.random.RandomGenerator;


private static final RandomGenerator RNG = RandomGenerator.of("L64X128MixRandom");
private static final int ROUNDS_PER_DAY = 30;
private static final int DAYS_TO_SIMULATE = 30;
private static final int INITIAL_WALLET = 1000;

void main() {

    simulateWithHistory(DAYS_TO_SIMULATE, INITIAL_WALLET);
}

private void simulateWithHistory(int days, int wallet) {
    int betAmount = 5;

    for (int day = 1; day <= days; day++) {
        for (int round = 0; round < ROUNDS_PER_DAY; round++) {
            int result = RNG.nextInt(1, 1001);
            wallet += (result <= 475) ? betAmount : -betAmount;
        }

        boolean bankrupt = wallet <= 0;
        IO.println("Day " + day + " | Final Balance: $" + wallet);

        if (bankrupt) {
            break;
        }
    }
}
