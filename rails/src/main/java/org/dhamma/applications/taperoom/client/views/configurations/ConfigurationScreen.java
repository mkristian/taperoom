/**
 *
 */
package org.dhamma.applications.taperoom.client.views.configurations;

import org.dhamma.applications.taperoom.client.models.Configuration;
import org.dhamma.applications.taperoom.client.models.ConfigurationFactory;

import de.saumya.gwt.session.client.Session;
import de.saumya.gwt.session.client.models.LocaleFactory;
import de.saumya.gwt.translation.common.client.GetTextController;
import de.saumya.gwt.translation.common.client.widget.HyperlinkFactory;
import de.saumya.gwt.translation.common.client.widget.LoadingNotice;
import de.saumya.gwt.translation.common.client.widget.NotificationListeners;
import de.saumya.gwt.translation.common.client.widget.ResourceBindings;
import de.saumya.gwt.translation.common.client.widget.ResourceHeaderPanel;
import de.saumya.gwt.translation.common.client.widget.ResourcePanel;
import de.saumya.gwt.translation.common.client.widget.SingletonResourceActionPanel;
import de.saumya.gwt.translation.common.client.widget.SingletonResourceScreen;

public class ConfigurationScreen extends SingletonResourceScreen<Configuration> {

    private static class ConfigurationHeaders extends
            ResourceHeaderPanel<Configuration> {

        public ConfigurationHeaders(final GetTextController getTextController) {
            super(getTextController);
        }

        public void reset(final Configuration resource) {
            reset(resource.updatedAt, resource.updatedBy);
        }
    }

    public ConfigurationScreen(final LoadingNotice loadingNotice,
            final GetTextController getTextController,
            final ConfigurationFactory factory,
            final LocaleFactory localeFactory, final Session session,
            final ResourceBindings<Configuration> bindings,
            final NotificationListeners listeners,
            final HyperlinkFactory hyperlinkFactory) {
        super(loadingNotice,
                factory,
                session,
                new ResourcePanel<Configuration>(new ConfigurationHeaders(getTextController),
                        new ConfigurationFields(getTextController,
                                bindings,
                                localeFactory)),
                new SingletonResourceActionPanel<Configuration>(getTextController,
                        bindings,
                        session,
                        factory,
                        listeners,
                        hyperlinkFactory),
                listeners,
                hyperlinkFactory);
    }

}
