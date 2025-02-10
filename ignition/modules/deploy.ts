import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const studentManagementModule = buildModule("studentManagementModule", (m) => {
  const studentManagement = m.contract("StudentManagement");

  return { studentManagement };
});

export default studentManagementModule;
