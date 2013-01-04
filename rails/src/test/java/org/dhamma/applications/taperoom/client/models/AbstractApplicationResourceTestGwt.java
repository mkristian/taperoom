package org.dhamma.applications.taperoom.client.models;

import de.saumya.gwt.persistence.client.SingletonResource;
import de.saumya.gwt.session.client.AbstractUserSingletonResourceTestGwt;

abstract class AbstractApplicationResourceTestGwt<E extends SingletonResource<E>>
        extends AbstractUserSingletonResourceTestGwt<E> {

    @Override
    public String getModuleName() {
        return "org.dhamma.applications.taperoom.Taperoom";
    }
}
