package com.alex.jooqshop.hibernate;

import jakarta.persistence.EntityGraph;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.hibernate.Session;
import org.hibernate.graph.GraphSemantic;
import org.hibernate.query.range.Range;
import org.hibernate.query.restriction.Restriction;
import org.hibernate.query.specification.SelectionSpecification;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class TestHibernateRunner implements CommandLineRunner {

    @PersistenceContext
    private final EntityManager entityManager;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Session session = entityManager.unwrap(Session.class);

        // 2. Define the graph
        EntityGraph<User> graph = entityManager.createEntityGraph(User.class);
        graph.addAttributeNodes("profile", "orders");

        // 3. Execute the query
        User user = SelectionSpecification.create(User.class, "from User u")
                .restrict(Restriction.restrict(User.class, "username", Range.singleValue("alex_j")))
                .createQuery(session)
                .setEntityGraph(graph, GraphSemantic.LOAD)
                .getSingleResult();

        System.out.println("Fetched User: " + user.getUsername());
    }
}
