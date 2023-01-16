<script lang="ts">
import { defineComponent, PropType } from "vue";

export interface ScatterChartSeries {
	data: Array<[number, number]>;
	name?: string;
	color?: string;
}

export default defineComponent({
	name: "ScatterChart",
	props: {
		data: {
			type: Object as PropType<Array<ScatterChartSeries>>,
			required: true,
		},
		name: {
			type: String,
			default: "-",
		},
	},
	data() {
		return {
			options: {
				legend: {
					position: "bottom",
					fontSize: "16px",
					show: true,
					showForSingleSeries: false,
					labels: {
						useSeriesColors: true,
					},
				},
				tooltip: {
					enabled: false,
				},
				xaxis: {
					tickAmount: 10,
					labels: {
						style: {
							fontSize: "16px",
							colors: "#ffffff",
						},
					},
					title: {
						text: "czas [s]",
						style: {
							color: "#ffffff",
							fontWeight: "normal",
							fontSize: "16px",
						},
					},
				},
				yaxis: {
					tickAmount: 20,
					min: 20,
					max: 33,
					axisBorder: {
						show: true,
						color: "#ffffff",
					},
					labels: {
						style: {
							fontSize: "16px",
							colors: "#ffffff",
						},
					},
					title: {
						text: "temperatura [°C]",
						style: {
							color: "#ffffff",
							fontWeight: "normal",
							fontSize: "16px",
						},
					},
					axisTicks: {
						show: true,
					},
				},
				chart: {
					zoom: {
						enabled: false,
					},
					toolbar: {
						show: false,
					},
					animations: {
						enabled: false,
					},
					type: "scatter",
				},
				grid: {
					borderColor: "rgba(255,255,255,0.1)",
					strokeDashArray: 0,
					xaxis: {
						lines: {
							show: true,
						},
					},
					yaxis: {
						lines: {
							show: true,
						},
					},
				},
				markers: {
					size: 4,
					strokeWidth: 0,
				},
			},
		};
	},
});
</script>

<template>
	<apexchart
		ref="chart"
		class="flex justify-center items-center w-10/12 max-w-screen-xl h-full"
		type="scatter"
		:options="options"
		:series="data"
	/>
</template>
