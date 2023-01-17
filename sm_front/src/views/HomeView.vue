<script lang="ts">
// @ts-nocheck
import { defineComponent } from "vue";
import {
	default as ScatterChart,
	ScatterChartSeries,
} from "../components/ScatterChart.vue";

class LineBreakTransformer {
	constructor() {
		this.container = "";
	}

	transform(chunk, controller) {
		this.container += chunk;
		const lines = this.container.split("\r\n");
		this.container = lines.pop();
		lines.forEach((line) => controller.enqueue(line));
	}

	flush(controller) {
		controller.enqueue(this.container);
	}
}

export default defineComponent({
	name: "HomeView",
	components: { ScatterChart },
	data() {
		return {
			baudRate: 115200,
			connResult: "",
			interval: null,
			port: null,
			points: { data: [], name: "przebieg wyjścia (temperatury)" },
			ref_points: { data: [], name: "wartość zadana" },
			Uref: 28,
		};
	},
	mounted() {
		if (!("serial" in navigator)) {
			alert(
				"Inną przeglądarke trzeba bo navigator nie jest rozbudowany (chrome i edge działa)"
			);
		}
	},
	unmounted() {
		clearInterval(interval);
	},
	methods: {
		async readData() {
			if (
				!this.port ||
				!this.port.readable ||
				this.port.readable.locked
			) {
				return;
			}

			const reader = this.port.readable
				.pipeThrough(new TextDecoderStream())
				.pipeThrough(new TransformStream(new LineBreakTransformer()))
				.getReader();

			try {
				while (true) {
					const { value, done } = await reader.read();

					if (done) {
						break;
					}

					console.log(value);

					try {
						const json = JSON.parse(value);
						const xy = [0, json.Temp];

						if (this.points.data.at(-1) !== undefined) {
							xy[0] = this.points.data.at(-1).at(0) + 1;
						} else {
							this.Uref = json.Uref;
						}

						this.ref_points.data.push([xy[0], json.Uref]);
						this.points.data.push(xy);

						if (this.ref_points.data.length > 60 * 5) {
							// if more than 5 mins of data assuming fs=1
							this.ref_points.data.shift();
							this.points.data.shift();
						}
					} catch (e) {
						console.error(e);
					}
				}
			} catch (err) {
				console.error(err);
			}

			reader.releaseLock();
		},
		async handleConnection() {
			Promise.resolve(navigator.serial.requestPort()).then((port) => {
				this.port = port;
				Promise.resolve(port.open({ baudRate: this.baudRate }))
					.then((_) => (this.connResult = "połączono"))
					.catch((_) => (this.conResult = "error"))
					.finally(() => {
						this.interval = setInterval(this.readData, 1000);
					});
			});
		},

		async disconnect() {
			Promise.resolve(navigator.serial.getPorts())
				.then((res) => {
					res.forEach((port) => {
						Promise.resolve(port.forget());
					});
				})
				.finally(() => (this.connResult = "rozłączono"));
		},

		async updatePIDSettings() {
			const encoder = new TextEncoder();
			const writer = this.port.writable.getWriter();
			const msg = `{"Uref":${this.Uref}}\r\n`;
			Promise.resolve(writer.write(encoder.encode(msg))).finally(() =>
				console.log(msg)
			);
			writer.releaseLock();
		},

		saveData() {
			const a = document.createElement("a");
			a.href = URL.createObjectURL(
				new Blob(
					[JSON.stringify([this.points, this.ref_points], null, 2)],
					{
						type: "text/json",
					}
				)
			);
			a.setAttribute("download", "data.json");
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
		},

		clearData() {
			this.points.data = [];
			this.ref_points.data = [];
		},
	},
});
</script>

<style>
.parent {
	display: grid;
	grid-template-columns: 4fr 1fr;
	grid-template-rows: 1fr;
	grid-column-gap: 0px;
	grid-row-gap: 0px;
}
.div1 {
	grid-area: 1 / 1 / 2 / 2;
}
.div2 {
	grid-area: 1 / 2 / 2 / 3;
}
</style>

<template>
	<div class="w-full h-full parent">
		<div class="div2 flex flex-col flex-nowrap pr-4 pl-4">
			<div class="mt-12">Status: {{ connResult }}</div>
			<div class="flex flex-nowrap content-between mt-3">
				<div>Prędkość transmisji:</div>
				<select v-model="baudRate" class="bg-[#242424] cursor-pointer">
					<option
						v-for="br of [
							110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200,
							38400, 57600, 115200, 128000, 256000,
						]"
						:value="br"
					>
						{{ br }}
					</option>
				</select>
			</div>
			<form>
				<div class="mt-3">
					<label class="w-1/5" for="Uref">Uref:</label>
					<input
						class="ml-3 p-0 bg-[#242424] w-[50px]"
						name="Uref"
						type="number"
						v-model="Uref"
					/>
					°C
				</div>
				<div class="mt-3">
					Aktualna temp.: {{ points.data.at(-1)?.at(1) ?? -1 }} °C
				</div>
			</form>
			<button
				class="p-2 mt-3 rounded-xl m-2 bg-blue-700 border-white"
				@click="updatePIDSettings"
			>
				Zaktualizuj nastawy
			</button>
			<button
				class="p-2 rounded-xl m-2 bg-orange-600 border-white"
				@click="saveData"
			>
				pobierz dane
			</button>
			<button
				class="p-2 rounded-xl m-2 bg-red-700 border-white"
				@click="clearData"
			>
				Wyczyść wykres
			</button>
			<button
				class="p-2 rounded-xl m-2 bg-green-700 border-white"
				@click="handleConnection"
			>
				Połącz
			</button>
			<button
				class="p-2 rounded-xl m-2 bg-red-700 border-white"
				@click="disconnect"
			>
				Rozłącz
			</button>
		</div>
		<div class="div1 flex justify-center items-center">
			<scatter-chart :data="[points, ref_points]" />
		</div>
	</div>
</template>
