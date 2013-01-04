/**
 *
 */
package org.dhamma.applications.taperoom.client.views.configurations;

import org.dhamma.applications.taperoom.client.models.Configuration;

import de.saumya.gwt.persistence.client.ResourceCollection;
import de.saumya.gwt.persistence.client.ResourcesChangeListener;
import de.saumya.gwt.session.client.models.Locale;
import de.saumya.gwt.session.client.models.LocaleFactory;
import de.saumya.gwt.translation.common.client.GetTextController;
import de.saumya.gwt.translation.common.client.widget.ResourceBindings;
import de.saumya.gwt.translation.common.client.widget.ResourceFields;
import de.saumya.gwt.translation.gui.client.bindings.CheckBoxBinding;
import de.saumya.gwt.translation.gui.client.bindings.IntegerTextBoxBinding;
import de.saumya.gwt.translation.gui.client.bindings.ListBoxBinding;
import de.saumya.gwt.translation.gui.client.bindings.TextBoxBinding;

public class ConfigurationFields extends ResourceFields<Configuration> {

    public ConfigurationFields(final GetTextController getTextController,
            final ResourceBindings<Configuration> bindings,
            final LocaleFactory localeFactory) {
        super(getTextController, bindings);
        add("idle session timeout for admins (in minutes)",
            new IntegerTextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.sessionIdleTimeout + "");
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.sessionIdleTimeout = Integer.parseInt(getText());
                }
            },
            1,
            Integer.MAX_VALUE);
        add("idle session timeout for downloads (in minutes)",
            new IntegerTextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.downloadSessionIdleTimeout);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.downloadSessionIdleTimeout = getTextAsInt();
                }
            },
            1,
            Integer.MAX_VALUE);
        add("audit log rotation (in days)",
            new IntegerTextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.keepAuditLogs);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.keepAuditLogs = getTextAsInt();
                }
            },
            1,
            Integer.MAX_VALUE);
        add("download tickets time to live (in days)",
            new IntegerTextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.timeToLive);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.timeToLive = getTextAsInt();
                }
            },
            1,
            Integer.MAX_VALUE);
        add("download tickets time to archive (in days)",
            new IntegerTextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.timeToArchive);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.timeToArchive = getTextAsInt();
                }
            },
            1,
            Integer.MAX_VALUE);
        add("email address of sender for error notification",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.notificationSenderEmail);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.notificationSenderEmail = getText();
                }
            },
            64);
        add("email recipients for error notification (comma separated list)",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.notificationRecipientEmails);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.notificationRecipientEmails = getText();
                }
            },
            254);
        add("IP of host when changed then an email gets send",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.localIp);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.localIp = getText();
                }
            },
            16);
        add("email address for changes in host IP",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.sendIpEmail);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.sendIpEmail = getText();
                }
            },
            64);
        add("email address of sender for password emails",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.passwordSenderEmail);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.passwordSenderEmail = getText();
                }
            },
            64);
        add("login url for new user emails",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.loginUrl);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.loginUrl = getText();
                }
            },
            128);
        add("directory for log files", new TextBoxBinding<Configuration>() {

            @Override
            public void pullFrom(final Configuration resource) {
                setText(resource.logfilesDirectory);
            }

            @Override
            public void pushInto(final Configuration resource) {
                resource.logfilesDirectory = getText();
            }
        }, 192);
        add("directory for error dumps", new TextBoxBinding<Configuration>() {

            @Override
            public void pullFrom(final Configuration resource) {
                setText(resource.errorsDumpDirectory);
            }

            @Override
            public void pushInto(final Configuration resource) {
                resource.errorsDumpDirectory = getText();
            }
        }, 192);
        add("download directory", new TextBoxBinding<Configuration>() {

            @Override
            public void pullFrom(final Configuration resource) {
                setText(resource.downloadDirectory);
            }

            @Override
            public void pushInto(final Configuration resource) {
                resource.downloadDirectory = getText();
            }
        }, 192);
        add("temporary download directory",
            new TextBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setText(resource.tmpDownloadDirectory);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.tmpDownloadDirectory = getText();
                }
            },
            192);
        add("dropbox directory", new TextBoxBinding<Configuration>() {

            @Override
            public void pullFrom(final Configuration resource) {
                setText(resource.dropboxDirectory);
            }

            @Override
            public void pushInto(final Configuration resource) {
                resource.dropboxDirectory = getText();
            }
        }, 192);
        add("maintenance mode - only root can log in",
            new CheckBoxBinding<Configuration>() {

                @Override
                public void pullFrom(final Configuration resource) {
                    setValue(resource.maintenanceMode);
                }

                @Override
                public void pushInto(final Configuration resource) {
                    resource.maintenanceMode = getValue();
                }
            });

        final ListBoxBinding<Configuration, Locale> locales = new ListBoxBinding<Configuration, Locale>(true) {

            @Override
            public void pullFrom(final Configuration resource) {
                setEnabled(getItemCount() > 0);
                selectAll(resource.locales);
            }

            @Override
            public void pushInto(final Configuration resource) {
                resource.locales = getResources(localeFactory);
            }
        };
        localeFactory.realLocales(new ResourcesChangeListener<Locale>() {

            @Override
            public void onLoaded(final ResourceCollection<Locale> resources) {
                locales.reset(resources);
            }
        });
        add("available locales for the UI", locales);

    }
}
