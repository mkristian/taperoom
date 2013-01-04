/**
 *
 */
package org.dhamma.applications.taperoom.client.models;

import de.saumya.gwt.persistence.client.AbstractResource;
import de.saumya.gwt.session.client.models.LocaleFactory;

public class ConfigurationTestGwt extends
        AbstractApplicationResourceTestGwt<Configuration> {

    private Configuration       resource;

    private static final String RESOURCE_XML = "<configuration>"
                                                     + "<session_idle_timeout>1</session_idle_timeout>"
                                                     + "<download_session_idle_timeout>12</download_session_idle_timeout>"
                                                     + "<keep_audit_logs>0</keep_audit_logs>"
                                                     + "<password_sender_email>password@email.com</password_sender_email>"
                                                     + "<login_url>example.com</login_url>"
                                                     + "<errors_dump_directory>log/errors</errors_dump_directory>"
                                                     + "<logfiles_directory>log</logfiles_directory>"
                                                     + "<time_to_live>0</time_to_live>"
                                                     + "<time_to_archive>0</time_to_archive>"
                                                     + "<locales></locales>"
                                                     + "<maintenance_mode>false</maintenance_mode>"
                                                     + "<updated_at>2009-07-09 17:14:48.0</updated_at>"
                                                     + "</configuration>";

    @Override
    protected String resourceNewXml() {
        return RESOURCE_XML.replaceFirst("<updated_at>[0-9-:. ]*</updated_at>",
                                         "");
    }

    @Override
    protected String resource1Xml() {
        return RESOURCE_XML;
    }

    @Override
    protected ConfigurationFactory factorySetUp() {
        return new ConfigurationFactory(this.repository,
                this.notifications,
                this.userFactory,
                new LocaleFactory(this.repository, this.notifications));
    }

    @Override
    protected AbstractResource<Configuration> resourceSetUp() {
        this.resource = this.factory.newResource();

        this.resource.sessionIdleTimeout = 1;
        this.resource.downloadSessionIdleTimeout = 12;
        this.resource.passwordSenderEmail = "password@email.com";
        this.resource.loginUrl = "example.com";
        this.resource.errorsDumpDirectory = "log/errors";
        this.resource.logfilesDirectory = "log";

        this.repository.addXmlResponse(RESOURCE_XML);

        this.resource.save();

        return this.resource;
    }

    @Override
    public void doTestCreate() {
        assertEquals("1", this.resource.sessionIdleTimeout + "");
    }

    @Override
    public void doTestUpdate() {
        this.resource.sessionIdleTimeout = Integer.parseInt(changedValue());
        this.resource.save();
        assertEquals(this.resource.sessionIdleTimeout + "", changedValue());
    }

    private final static String XML = "<configuration>"
                                            + "<session_idle_timeout>1</session_idle_timeout>"
                                            + "<keep_audit_logs>0</keep_audit_logs>"
                                            + "<locales></locales>"
                                            + "<updated_at>2007-07-09 17:14:48.0</updated_at>"
                                            + "</configuration>";

    @Override
    protected String changedValue() {
        return "2";
    }

    @Override
    protected String marshallingXml() {
        return XML;
    }

    @Override
    protected String value() {
        return "1";
    }
}
