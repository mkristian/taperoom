package org.dhamma.applications.taperoom.client;

import org.dhamma.applications.taperoom.client.models.Configuration;
import org.dhamma.applications.taperoom.client.models.ConfigurationFactory;
import org.dhamma.applications.taperoom.client.views.configurations.ConfigurationScreen;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.ui.RootPanel;

import de.saumya.gwt.translation.common.client.route.ScreenController;
import de.saumya.gwt.translation.common.client.widget.ResourceBindings;
import de.saumya.gwt.translation.gui.client.GUIContainer;

// need that Application classname to work with gwt-ixtlan generators
public class Application implements EntryPoint {

    @Override
    public void onModuleLoad() {
        final GUIContainer container = new GUIContainer(RootPanel.get());
        final ScreenController screenController = container.screenController;

        final ConfigurationFactory configurationFactory = new ConfigurationFactory(container.repository,
                container.notifications,
                container.userFactory,
                container.localeFactory);
        final ConfigurationScreen configurationScreen = new ConfigurationScreen(container.loadingNotice,
                container.getTextController,
                configurationFactory,
                container.localeFactory,
                container.session,
                new ResourceBindings<Configuration>(),
                container.listeners,
                container.hyperlinkFactory);
        screenController.addScreen(configurationScreen, "configurations");

        screenController.redirectDefault();
    }
}
