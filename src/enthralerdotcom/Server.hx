package enthralerdotcom;

import monsoon.Monsoon;
import monsoon.middleware.Console;
import smalluniverse.SmallUniverse;
import dodrugs.Injector;
import sys.db.*;
import ufront.db.migrations.*;
using tink.core.Outcome;

class Server {
	static function main() {

		Manager.cnx = Mysql.connect({
			host: Sys.getEnv('DB_HOST'),
			database: Sys.getEnv('DB_DATABASE'),
			user: Sys.getEnv('DB_USERNAME'),
			pass: Sys.getEnv('DB_PASSWORD'),
		});

		var injector = Injector.create('enthralerdotcom', [
			var _:Connection = Manager.cnx,
			MigrationConnection,
			MigrationManager,
			MigrationApi,
			enthralerdotcom.templates.ManageTemplatesPage,
			enthralerdotcom.templates.TemplatesApi,
		]);

		if (php.Web.isModNeko) {
			webMain(injector);
		} else {
			cliMain(injector);
		}
	}

	static function webMain(injector:Injector<'enthralerdotcom'>) {
		var app = new Monsoon();

		var smallUniverse = new SmallUniverse(app);
		smallUniverse.addPage('/templates', function () return injector.get(enthralerdotcom.templates.ManageTemplatesPage));
		smallUniverse.addPage('/templates/:name', function () return injector.get(enthralerdotcom.templates.ViewTemplatePage));
		// // smallUniverse.addPage('/i/:guid', ItemPage);
		// // smallUniverse.addPage('/i/:guid/edit', ItemEditorPage);
		app.listen(3000);
	}

	static function cliMain(injector:Injector<'enthralerdotcom'>) {
		var migrationApi = injector.get(MigrationApi);
		migrationApi.ensureMigrationsTableExists();
		migrationApi.syncMigrationsUp().sure();
		trace('done');
	}
}
