const routes_extension = [
  {
    path: "/",
    component: () => import("layouts/dacLayout.vue"),
    children: [
      {
        path: "example",
        component: () => import("../pages/example")
      }
    ]
  },
  {
    path: "/vigorapp",
    component: () => import("../layouts/appLayout.vue"),
    children: [
      { path: "", component: () => import("../pages/app1.vue") },
      { path: "app_page1", component: () => import("../pages/app1.vue") },
      {
        path: "airburn",
        component: () => import("../pages/airburn.vue")
      }
    ]
  }
];

export default routes_extension;
