package com.alex.jooqshop;

import com.alex.jooqshop.db.tables.pojos.Users;
import com.alex.jooqshop.db.tables.records.ProfilesRecord;
import com.alex.jooqshop.db.tables.records.PurchaseOrdersRecord;
import com.alex.jooqshop.db.tables.records.UsersRecord;
import lombok.RequiredArgsConstructor;
import org.jooq.DSLContext;
import org.jooq.Records;
import org.jspecify.annotations.NonNull;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

import static com.alex.jooqshop.db.Tables.PROFILES;
import static com.alex.jooqshop.db.Tables.PURCHASE_ORDERS;
import static com.alex.jooqshop.db.Tables.USERS;
import static org.jooq.impl.DSL.multiset;
import static org.jooq.impl.DSL.selectFrom;

@Component
@RequiredArgsConstructor
public class DataRunner implements CommandLineRunner {


    private final DSLContext dslContext;

    @Override
    public void run(String @NonNull ... args) {
    }


    private void insertExample() {
        var newUser = new Users().setUsername("jooq_fan");
        dslContext.newRecord(USERS, newUser).insert();
    }

    private void deleteExample() {
        dslContext.deleteFrom(USERS)
                .where(USERS.USERNAME.eq("jooq_fan"))
                .execute();
    }

    private void secondWay() {
        List<UserProjection> results = dslContext.select(
                        USERS,
                        PROFILES,
                        multiset(selectFrom(PURCHASE_ORDERS).where(PURCHASE_ORDERS.USER_ID.eq(USERS.ID)))
                )
                .from(USERS)
                .leftJoin(PROFILES).on(PROFILES.USER_ID.eq(USERS.ID))
                .where(USERS.USERNAME.eq("alex_j"))
                .fetch(Records.mapping(UserProjection::new));

        results.forEach(p -> {
            IO.println("Second way");
            IO.println(p);
        });
    }

    public record UserProjection(UsersRecord user,
                                 ProfilesRecord profile,
                                 List<PurchaseOrdersRecord> purchaseOrders) {

    }
}
